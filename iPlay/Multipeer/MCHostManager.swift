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
    var secondsElapsed: Double = 0.0
    var timer: Timer?
    
    var viewState: ViewState = .preLobby
    var gameState: GameState = .Infected
    
    var spectrumGameState: SpectrumGameState = .instructions
    var spectrumPrompt: SpectrumPrompt?
    var spectrumGuesses = [PlayerGuess]()
    
#if os(macOS)
    var emojiMatchImages: [MCPeerID : NSImage] = [:]
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
    
    func infectScore(infectorIndex: Int, infectedIndex: Int) {
//        let basePoints = Int(ceil(120.0 / Double(infectedPlayers.count - 1)))
        
        if !infectedPlayers[infectedIndex].isInfected {
            infectedPlayers[infectorIndex].points += 20
            infectedPlayers[infectedIndex].isInfected = true
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
            //Add Additional Cases Here:
            case "emojiMatchImage":
                guard let data = mcData.data else {
                    print("NO Data recieved")
                    return
                }
#if os(macOS)
                let image = NSImage(data: data)
                emojiMatchImages[peerID] = image
#endif
            default:
                print("Unhandled ID: \(mcData.id)")
            }
            
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
        
        //Accepts the invitation request
        gameParticipants.insert(Player(id: peerID))
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
    //Add other Multipeer Connectivity send functions here:
}
