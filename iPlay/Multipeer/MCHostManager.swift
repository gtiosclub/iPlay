//
//  MCHostManager.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import Foundation
import MultipeerConnectivity
#if os(macOS)
import AppKit
#endif

enum SpectrumGameState: Codable {
    case instructions, whosPrompting, hintSubmitted, revealingGuesses, pointsAwarded, guessing
}

/*
 MC Host Manager is the class containing the attributes and functions dictating the multipeer connectivity on the side of the Mac/Host
 */
@Observable
class MCHostManager: NSObject, ObservableObject {
    static var shared: MCHostManager?
    
    let serviceType = "iPlay"
    var advertiser: MCNearbyServiceAdvertiser
    var session: MCSession?
    var peer: MCPeerID
    
    var numInfected: Int = 0
    var gameParticipants = Set<Player>()
    var infectedPlayers: [InfectedPlayer] = []
    
    var dogFightPlayers: [DogFightPlayer] = []
    var dogFightBalls : [DogFightBall] = []
    
    var secondsElapsed: Double = 0.0
    var timer: Timer?
    
    var viewState: ViewState = .preLobby
    var gameState: GameState = .Infected
    
    var spectrumGameState: SpectrumGameState = .instructions
    var spectrumPrompt: SpectrumPrompt?
    var spectrumGuesses = [PlayerGuess]()
    
    var chainPlayers: [ChainPlayer] = []
    var endWord: String? = nil
    var chainStartWord: String? = nil
    var chainEndWord: String? = nil
    var completedChainPlayers: [MCPeerID] = []
    let wordBank = ["apple", "razor", "desert", "penguin", "moon", "fire", "water", "forest", "robot", "music", "shark", "keyboard", "snow", "book", "train", "dream", "camera", "storm", "clock", "planet"]

    
    #if os(macOS)
    var emojiMatchImages: [MCPeerID : NSImage] = [:]
    var emojiMatchScores: [MCPeerID : Double] = [:]
    var emojiMatchVotes: [MCPeerID : Int] = [:]
    var emojiMatchEmoji: EmojiTypes = .happy
    var emojiMatchAIVote: MCPeerID? = nil
    #endif

    init(name: String) {
        let peerID = MCPeerID(displayName: name)
        
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        peer = peerID
            
        super.init()
        
        session?.delegate = self
        advertiser.delegate = self
    }
    
    /*
     This function is how the singleton instance of the shared Multipeer Manager is created
     */
    static func createSharedInstance(name: String) {
        shared = MCHostManager(name: name)
    }
    
    /*
     Creates Lobby and Advertises it to other devices on the local network
     */
    func start() {
        advertiser.startAdvertisingPeer()
        print("Advertising and Looking for peers")
    }
    
    //*********  INFECTED  *********//
    func startInfectedGame() {
        secondsElapsed = 0.0
        numInfected = 0
        initializeScores()
        startTimer()
    }
    
    func initializeScores() {
        for i in infectedPlayers.indices {
            infectedPlayers[i].points = 0
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.secondsElapsed += 1.0
            
            for i in self.infectedPlayers.indices where !self.infectedPlayers[i].isInfected {
                self.infectedPlayers[i].points += 1
            }
            
        }
    }
    
    func endInfectedGame() {
        print("ending infected!")
        timer?.invalidate()
        timer = nil
        //Add game scores to total player scores
        var updatedPlayers = gameParticipants

        for infectedPlayer in infectedPlayers {
            if let player = gameParticipants.first(where: { $0.id == infectedPlayer.id }) {
                var updatedPlayer = player
                updatedPlayer.points += Int(infectedPlayer.points)
            
                updatedPlayers.remove(player)
                updatedPlayers.insert(updatedPlayer)
            }
        }
        gameParticipants = updatedPlayers
        viewState = .scoreboard
    }
    
    func endDogFightGame() {
        var updatedPlayers = gameParticipants

        for dogFightPlayer in dogFightPlayers {
            if let player = gameParticipants.first(where: { $0.id == dogFightPlayer.id }) {
                var updatedPlayer = player
                updatedPlayer.points += Int(dogFightPlayer.points)
            
                updatedPlayers.remove(player)
                updatedPlayers.insert(updatedPlayer)
            }
        }
        gameParticipants = updatedPlayers
        dogFightBalls = []
        dogFightPlayers = []
        viewState = .scoreboard
    }
    
    func infectScore(infectorIndex: Int, infectedIndex: Int) {
//        let basePoints = Int(ceil(120.0 / Double(infectedPlayers.count - 1)))
        
        if !infectedPlayers[infectedIndex].isInfected {
            infectedPlayers[infectorIndex].points += 20
            infectedPlayers[infectedIndex].isInfected = true
        }
    }
    
    //*********  CHAIN  *********//
    func getChainsByPlayer() -> [String: [String]] {
        var chainsByPlayer: [String: [String]] = [:]
        for player in chainPlayers {
            chainsByPlayer[player.name] = player.chain
        }
        return chainsByPlayer
    }
    
    func getChainLinksByPlayer() -> [String: [ChainLink]] {
        var result: [String: [ChainLink]] = [:]
        for player in chainPlayers {
            result[player.name] = player.chain.map { ChainLink(playerName: player.name, value: $0) }
        }
        return result
    }

    func applyChainPointsToGameParticipants() {
        var updatedPlayers = gameParticipants
        for chainPlayer in chainPlayers {
            if let player = gameParticipants.first(where: { $0.id == chainPlayer.id }) {
                var updatedPlayer = player
                updatedPlayer.points += chainPlayer.points
                updatedPlayers.remove(player)
                updatedPlayers.insert(updatedPlayer)
            }
        }
        gameParticipants = updatedPlayers
    }

    
    func startChainTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.secondsElapsed += 1.0
        }
    }
    
    func checkAllPlayersComplete() {
        if gameParticipants.count > 0 && completedChainPlayers.count == gameParticipants.count {
            allChainPlayersCompleted()
        }
    }
    
    func checkChainCompletion(word: String, fromPeer peerID: MCPeerID) -> Bool {
        // Case-insensitive comparison
        if word.lowercased() == chainEndWord?.lowercased() {
            // Make sure we don't add the player twice
            if !completedChainPlayers.contains(peerID) {
                // Add player to completed list in order of completion
                completedChainPlayers.append(peerID)
                
                // Calculate points based on finish position (1st gets most points)
                let position = completedChainPlayers.count
                
                // Award completion bonus, higher for earlier finishers
                // Example: 50 for 1st, 30 for 2nd, 20 for 3rd, 10 for completing
                var completionPoints = 0;
                
                switch position {
                case 1:
                    completionPoints = 50
                case 2:
                    completionPoints = 30
                case 3:
                    completionPoints = 20
                default:
                    completionPoints = 10
                }
                
                if let index = chainPlayers.firstIndex(where: { $0.id == peerID }) {
                    chainPlayers[index].points += completionPoints
                    print("\(peerID.displayName) completed chain in position \(position)! Awarded \(completionPoints) points")
                }
                
                // Check if all players are done
                checkAllPlayersComplete()
                
                return true
            }
        }
        return false
    }
    
    
    func allChainPlayersCompleted() {
        // This function gets called when all players have completed their chains
        // You can use this to transition to the next game state, show scores, etc.
        print("All players have successfully completed their word chains!")
        // Additional game end logic here
    }
    
    func generateChainWords() {
        // Simple implementation - could be enhanced with similarity checking
        guard wordBank.count >= 2 else { return }
        
        // Shuffle and pick two different words
        let shuffled = wordBank.shuffled()
        chainStartWord = shuffled[0].capitalized
        chainEndWord = shuffled[1].capitalized
        
        // Make sure they're different
        if chainStartWord == chainEndWord {
            chainEndWord = wordBank.filter { $0 != chainStartWord?.lowercased() }.randomElement()?.capitalized
        }
        
        // Send to all connected peers
        sendChainWords()
    }
    
    func sendChainWords() {
        guard let session = session,
              let start = chainStartWord,
              let end = chainEndWord else {
            print("Cannot send chain words - missing session or words")
            return
        }
        
        do {
            var mcData = MCData(id: "chainWords")
            let chainWordPair = ChainWordPair(startWord: start, endWord: end)
            try mcData.encodeData(id: "chainWords", data: chainWordPair)
            let data = try JSONEncoder().encode(mcData)
            
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("Sent chain words: \(start) → \(end)")
        } catch {
            print("Failed to send chain words: \(error)")
        }
    }
    
}

extension MCHostManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //TODO: Fill in for changing session state
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            var mcData = try JSONDecoder().decode(MCData.self, from: data)
            switch mcData.id {
            case "infectedVector":
                let vector_data = try mcData.decodeData(id: mcData.id, as: Vector.self)
                infectedPlayers.first(where: {$0.id.displayName == peerID.displayName})?.move(by: vector_data)
            case "dogFightVector":
                let angle_data = try mcData.decodeData(id: mcData.id, as: MCDataFloat.self)
                if let index = dogFightPlayers.firstIndex(where: { $0.id.displayName == peerID.displayName }) {
                    dogFightPlayers[index].updateHeading(by: angle_data)
                }
            case "shootBall":
                //Find player who shot the ball and create ball with their heading
                if let index = dogFightPlayers.firstIndex(where: {$0.id.displayName == peerID.displayName}) {
                    let heading = dogFightPlayers[index].heading
                    var position = dogFightPlayers[index].playerObject.position
                    let  velocity = CGVector(dx: heading.x * 250, dy: heading.y * 250)
                    //Move ball ahead so it doesn't collide with ball
                    position.x += heading.x * 90
                    position.y += heading.y * 90
                    
                    dogFightBalls.append(DogFightBall(velocity: velocity, position: position))
                }
            case "spectrumHintFromPrompter":
                let prompt = try mcData.decodeData(id: mcData.id, as: MCDataString.self)
                print("Recieved hint: \(prompt.message)")
                sendHint(data, peerID)
                self.spectrumGameState = .guessing
            case "spectrumGuess":
                let guess = try mcData.decodeData(id: mcData.id, as: MCDataFloat.self)
                print("Recieved guess from: \(peerID.displayName): \(guess.num)")
                spectrumGuesses.append(PlayerGuess(playerName: peerID.displayName, value: guess.num))
                if spectrumGuesses.count == gameParticipants.count - 1 {
                    //Do scoring
                    sendSpectrumState(.revealingGuesses)
                }
            case "chainLinks":
                let links = try mcData.decodeData(id: mcData.id, as: [ChainLink].self)
                let words = links.map { $0.value }
                print("Received chain from \(peerID.displayName): \(words.joined(separator: " → "))")
                
                if let index = chainPlayers.firstIndex(where: { $0.id == peerID }) {
                    chainPlayers[index].chain = words
                    let _ = checkChainCompletion(word: words.last!, fromPeer: peerID)
                } else {
                    let newPlayer = ChainPlayer(id: peerID, name: peerID.displayName, points: 0, chain: words)
                    chainPlayers.append(newPlayer)
                }
            
            case "EmojiMatchPicture":
                print("RECIEVED IMAGE FROM PLAYERRRRRR")
                guard let data = mcData.data else {
                    print("NO Data recieved")
                    return
                }
#if os(macOS)
                let image = NSImage(data: data)
                emojiMatchImages[peerID] = image
#endif
            case "emojiMatchConfidence":
                print("Recieved Confidence from player")
                let confidence = try mcData.decodeData(id: "emojiMatchConfidence", as: MCDataFloat.self)
#if os(macOS)
                emojiMatchScores[peerID] = confidence.num
#endif
            case "emojiMatchOtherPlayers":
                let players = try mcData.decodeData(id: "emojiMatchOtherPlayers", as: [CodablePlayer].self)
#if os(macOS)
                guard let vote = players.first else {
                    print("Invalid vote cast")
                    return
                }
                let player = gameParticipants.first { p in
                    p.username == vote.name
                }
                if let id = player?.id {
                    emojiMatchVotes[id, default: 0] += 1
                }
#endif
            default:
                print("Unhandled ID: \(mcData.id)")
            }
            
            //Add Additional Cases Here:
            
        } catch {
            print("Error decoding: \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        //TODO: Fill in for recieving input stream
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        //TODO: Fill in for starting recieving resource
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        //TODO: Fill in for finishing recieving resource
    }
}

extension MCHostManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        var avatar = "DefaultAvatar"
        if let context = context {
            do {
                avatar = try JSONDecoder().decode(String.self, from: context)
            } catch {
                print("Failed to decode avatar from context: \(error)")
            }
        }
        //Accepts the invitation request
        gameParticipants.insert(Player(id: peerID, avatar: avatar))
        invitationHandler(true, session)
    }
}


extension MCHostManager {
    //SPECTRUM
    //Sends the prompt to the other players
    func sendHint(_ promptData: Data, _ sender: MCPeerID) {
        guard let session else {
            print("Could not send prompt, no session active")
            return
        }
        
        do {
            let recipients = gameParticipants.compactMap { player in
                player.id == sender ? nil : player.id
            }
            
            guard !recipients.isEmpty else {
                print("NOBODY TO SEND HINT TO")
                return
            }
            
            try session.send(promptData, toPeers: recipients, with: .reliable)
            print("Send hint")
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    //GAME STATE MANAGEMENT
    func sendGameState() {
        guard let session else {
            print("Could not send game state, no session active")
            return
        }
        
        do {
            var mcData = MCData(id:"gameStateManagement")
            try mcData.encodeData(id: "gameStateManagement", data: gameState)
            let data = try JSONEncoder().encode(mcData)
            
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    //SPECTRUM: GAME STATE MANAGEMENT
    func sendSpectrumState(_ spectrumStateData: SpectrumGameState) {
        guard let session else {
            print("Could not send game state, no session active")
            return
        }
        
        do {
            var mcData = MCData(id:"spectrumGameState")
            try mcData.encodeData(id: "spectrumGameState", data: spectrumStateData)
            let data = try JSONEncoder().encode(mcData)
            
            let participantIDs: [MCPeerID] = gameParticipants.compactMap { player in
                player.id
            }
            try session.send(data, toPeers: participantIDs, with: .reliable)
            self.spectrumGameState = spectrumStateData
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
    
     //SPECTRUM:
    func sendPrompt(hinter: MCPeerID) {
        guard let session else {
            print("Could not send prompt, no session active")
            return
        }
        
        do {
            var promptData = MCData(id:"promptData")
            try promptData.encodeData(id: "promptData", data: SpectrumPrompt())
            
            guard let data = promptData.data else {
                print("Data failed")
                return
            }
            
            let recipients = session.connectedPeers.filter { $0 != hinter }
            try session.send(data, toPeers: recipients, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    func sendOutInitialSpectrumData() {
        guard let session else {
            print("Could not send spectrum data, no session active")
            return
            
        }
        guard gameParticipants.count > 1 else {
            print("Could not send out initital spectrum data: Not enought participants")
            return
        }
        
        print("There are currently: \(gameParticipants.count) players")
        
        let hinter = gameParticipants.randomElement()
        guard let hinter else {
            print("NO RANDOM HINTER FOUND")
            return
        }
        
        do {
            var promptData = MCData(id:"spectrumPrompt")
            let prompt = SpectrumPrompt()
            self.spectrumPrompt = prompt
            try promptData.encodeData(id: "spectrumPrompt", data: prompt)
            var data = try JSONEncoder().encode(promptData)
            
            let participants: [MCPeerID] = gameParticipants.compactMap { participant in
                participant == hinter ? nil : participant.id
            }
            
            try session.send(data, toPeers: participants, with: .reliable)
            prompt.isHinter = true
            try promptData.encodeData(id: "spectrumPrompt", data: prompt)
            data = try JSONEncoder().encode(promptData)
            try session.send(data, toPeers: [hinter.id], with: .reliable)
            
            sendSpectrumState(.whosPrompting)
            self.spectrumGameState = .whosPrompting
        } catch {
            print("Failed to send data: \(error)")
        }
    }
    
    func sendInfectedState(_ state: MCInfectedState) {
        guard let session else {
            print("Could not send infected state, no session active")
            return
        }
        do {
            var mcData = MCData(id:"infectedState")
            try mcData.encodeData(id: "infectedState", data: state)
            let data = try JSONEncoder().encode(mcData)
            
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
        
    }
    
    func sendViewStateUpdate(_ newState: ViewState) {
        guard let session else {
            print("Could not send view state update, no session active")
            return
        }
        
        do {
            var mcData = MCData(id: "viewStateUpdate")
            try mcData.encodeData(id: "viewStateUpdate", data: newState)
            let data = try JSONEncoder().encode(mcData)
            
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            self.viewState = newState
            print("Sent view state update: \(newState)")
        } catch {
            print("Failed to send view state update: \(error.localizedDescription)")
        }
    }
    
    #if os(macOS)
    func pickOutEmoji() {
        emojiMatchEmoji = EmojiTypes.happy
    }
    
    func sendEmojiMatchState(state: EmojiMatchGameState) {
        guard let session else {
            print("No session")
            return
        }
        
        do {
            var mcData = MCData(id: "emojiMatchGameState")
            try mcData.encodeData(id: "emojiMatchGameState", data: state)
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: gameParticipants.map({ player in
                player.id
            }), with: .reliable)
        } catch {
            print("Failed to send Emoji Match Game State: \(error.localizedDescription)")
        }
    }
    
    func sendEmojiMatchEmoji() {
        guard let session else {
            print("No session")
            return
        }
        
        do {
            var mcData = MCData(id: "emojiMatchEmoji")
            try mcData.encodeData(id: "emojiMatchEmoji", data: emojiMatchEmoji)
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: gameParticipants.map({ player in
                player.id
            }), with: .reliable)
        } catch {
            print("Failed to send Emoji: \(error.localizedDescription)")
        }
    }
    
    //for voting
    func sendOutEmojiMatchPlayers() {
        guard let session else {
            print("No session")
            return
        }
        
        do {
            var codablePlayers = gameParticipants.map { player in
                CodablePlayer(name: player.username, avatar: player.avatar)
            }
            
            var mcData = MCData(id: "emojiMatchOtherPlayers")
            try mcData.encodeData(id: "emojiMatchOtherPlayers", data: codablePlayers)
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: gameParticipants.map({ player in
                player.id
            }), with: .reliable)
        } catch {
            print("Failed to send other players: \(error.localizedDescription)")
        }
    }
    
    func calculateAIVote() {
        var player: MCPeerID? = nil
        var max = 0.0
        for (k,v) in emojiMatchScores {
            if v > max {
                player = k
                max = v
            }
        }
        
        if let player {
            emojiMatchVotes[player, default: 0] += 1
            emojiMatchAIVote = player
        }
        
        print(player?.displayName ?? "No ai vote")
    }
    #endif
    //Add other Multipeer Connectivity send functions here:
}
