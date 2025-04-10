//
//  MCPlayerManager.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import Foundation
import MultipeerConnectivity

/*
 MC Player Manager is the class containing the attributes and functions dictating the multipeer connectivity on the side of the iPhone/Player
 */
@Observable
class MCPlayerManager: NSObject {
    static var shared: MCPlayerManager?
    
    let serviceType = "iPlay"
    var browser: MCNearbyServiceBrowser
    var session: MCSession?
    
    var currentPlayer: Player
    var currentInfectedStatus: Bool = false
    var host: MCPeerID?
    var openLobbies = Set<Lobby>()
    
    var viewState: ViewState = .preLobby
    var gameState: GameState = .Infected
    
    var chainStartWord: String? = nil
    var chainEndWord: String? = nil
    var chainCompletionInfo: ChainCompletion? = nil
    
    
    //SPECTRUM
    var spectrumPhoneState: SpectrumPhoneState = .instructions
    
    enum SpectrumPhoneState: Codable {
        case instructions, youGivingPrompt, waitingForPrompter, waitForGuessers, youAreGuessing, revealingGuesses, pointsAwarded
    }
    var spectrumPrompt: SpectrumPrompt?
    var spectrumHint: String?
    
    
    private init(name: String) {
        let peerID = MCPeerID(displayName: name)
        currentPlayer = Player(id: peerID)
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        
        super.init()
        
        session?.delegate = self
        browser.delegate = self
    }
    
    /*
     This function is how the singleton instance of the shared Multipeer Manager is created
     */
    static func createSharedInstance(name: String) {
        shared = MCPlayerManager(name: name)
    }
    
    /*
     Looks for other peers on the local network
     */
    func start() {
        browser.startBrowsingForPeers()
        print("Looking for lobbies")
    }
}

extension MCPlayerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            print("Not Connected")
        case .connecting:
            print("Connecting")
        case .connected:
            //Player has joined a lobby
            if host == nil {
                print("IN GAME??? PeerID: \(peerID.displayName)")
                host = peerID
                viewState = .inLobby
            }
        @unknown default:
            print("Unknown State")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            var mcData = try JSONDecoder().decode(MCData.self, from: data)
            switch mcData.id {
            case "spectrumHintFromPrompter":
                let prompt = try mcData.decodeData(id: mcData.id, as: MCDataString.self)
                print("Recieved hint: \(prompt.message)")
                spectrumHint = prompt.message
                spectrumPhoneState = .youAreGuessing
            case "chainWords":
                let wordPair = try mcData.decodeData(id: mcData.id, as: ChainWordPair.self)
                print("Received chain words: \(wordPair.startWord) → \(wordPair.endWord)")
                self.chainStartWord = wordPair.startWord
                self.chainEndWord = wordPair.endWord
            case "chainCompletion":
                let completion = try mcData.decodeData(id: mcData.id, as: ChainCompletion.self)
                print("Chain completed! Position: \(completion.position) of \(completion.totalPlayers)")
                self.chainCompletionInfo = completion
            case "gameStateManagement":
                let newGameState = try mcData.decodeData(id: mcData.id, as: GameState.self)
                gameState = newGameState
                viewState = .inGame
                print("recieved game state: ", gameState)
            case "spectrumGameState":
                let spectrumGameState = try mcData.decodeData(id: mcData.id, as: SpectrumGameState.self)
                print("RECIEVED SPECTRUM GAME STATE: \(spectrumGameState)")
                //change view state based on stuff
                switch spectrumGameState {
                case .whosPrompting:
                    if let spectrumPrompt, spectrumPrompt.isHinter {
                        spectrumPhoneState = .youGivingPrompt
                        //view should go to you are prompter screen then go to writing prompt after 3? seconds
                    }
                    else {
                        spectrumPhoneState = .waitingForPrompter
                    }
                case .guessing:
                    if let spectrumPrompt, spectrumPrompt.isHinter {
                        spectrumPhoneState = .waitForGuessers
                    } else {
                        spectrumPhoneState = .youAreGuessing
                    }
                case .hintSubmitted:
                    spectrumPhoneState = .waitForGuessers
                case .revealingGuesses:
                    spectrumPhoneState = .revealingGuesses
                case .pointsAwarded:
                    spectrumPhoneState = .pointsAwarded
                default:
                    spectrumPhoneState = .instructions
                    print("Game state not handled: \(spectrumGameState)")
                }
            case "spectrumPrompt":
                let prompt = try mcData.decodeData(id: mcData.id, as: SpectrumPrompt.self)
                print("Decoded initial spectrum prompt: \(prompt.prompt)")
                self.spectrumPrompt = prompt
                //Add Additional Cases Here:
            case "infectedState":
                let infectedState = try mcData.decodeData(id: "infectedState", as: MCInfectedState.self)
                print(infectedState)
                if infectedState.playerID == self.currentPlayer.id.displayName {
                    currentInfectedStatus = infectedState.infected
                    print(currentPlayer)
                }
            case "viewStateUpdate":
                let newViewState = try mcData.decodeData(id: mcData.id, as: ViewState.self)
                print("Received view state update: \(newViewState)")
                viewState = newViewState
                
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



extension MCPlayerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        //Adds lobby to Lobby List
        openLobbies.insert(Lobby(id: peerID))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        //Removes lobby From Lobby List
        if openLobbies.contains(Lobby(id: peerID)) {
            openLobbies.remove(Lobby(id: peerID))
        }
    }
}


extension MCPlayerManager {
    //Send vector data by using JSON encoding of a Vector class
    func sendVector(v: Vector) {
        guard let session else {
            print("Session is nil")
            return
        }
        
        var mcData = MCData(id: "infectedVector")
        do {
            try mcData.encodeData(id: mcData.id, data: v)
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error)
            return
        }
    }
    
    func sendAngle(angle: Double) {
        guard let session else {
            print("Session is nil")
            return
        }
        var mcData = MCData(id: "dogFightVector")
        do {
            try mcData.encodeData(id: mcData.id, data: MCDataFloat(num:angle))
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error)
            return
        }
    }
    
    func shootBall() {
        guard let session else {
            print("Session is nil")
            return
        }
        var mcData = MCData(id: "shootBall")
        do {
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print(error)
            return
        }
    }
    
    //Spectrum: Sends the prompt to host, which then sends to other players
    func sendHint(_ prompt: String) {
        guard let session else {
            print("Session is nil")
            return
        }
        
        guard let host else {
            print("No host in session")
            return
        }
            
        var mcData = MCData(id: "spectrumHintFromPrompter")
        do {
            try mcData.encodeData(id: "spectrumHintFromPrompter", data: MCDataString(message: prompt))
            let data = try JSONEncoder().encode(mcData)
            try session.send(data, toPeers: [host], with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
        
        spectrumPhoneState = .waitForGuessers
    }
    
    func submitGuess(guess: CGFloat) {
        guard let session else {
            print("Session is nil")
            return
        }
        
        guard let host else {
            print("No host in session")
            return
        }
        
        let guessData = MCDataFloat(num: guess / 10.0)
        var mcGuessData = MCData(id: "spectrumGuess")
        do {
            try mcGuessData.encodeData(id: "spectrumGuess", data: guessData)
            let encodedGuess = try JSONEncoder().encode(mcGuessData)
            print("HOST: \(host.displayName)")
            try session.send(encodedGuess, toPeers: [host], with: .reliable)
        } catch {
            print("Failed to submit guess: \(error.localizedDescription)")
        }
    }
    
    func submitChainWord(_ word: String) {
        guard let session else {
            print("Session is nil")
            return
        }
        
        guard let host else {
            print("No host in session")
            return
        }
        
        var mcWordData = MCData(id: "chainWord")
        do {
            try mcWordData.encodeData(id: "chainWord", data: mcWordData)
            let encodedWord = try JSONEncoder().encode(mcWordData)
            print("HOST: \(host.displayName)")
            try session.send(encodedWord, toPeers: [host], with: .reliable)
        } catch {
            print("Failed to submit guess: \(error.localizedDescription)")
        }
    }
    
    func submitChainLinks(_ links: [ChainLink]) {
        guard let session else {
            print("Session is nil")
            return
        }
        
        guard let host else {
            print("No host in session")
            return
        }
        
        var mcLinksData = MCData(id: "chainLinks")
        do {
            try mcLinksData.encodeData(id: "chainLinks", data: links)
            let encodedLinks = try JSONEncoder().encode(mcLinksData)
            print("Sending chain links to HOST: \(host.displayName)")
            try session.send(encodedLinks, toPeers: [host], with: .reliable)
        } catch {
            print("Failed to submit chain links: \(error.localizedDescription)")
        }
    }
    
    // Add other Multipeer Connectivity send functions here:
}
