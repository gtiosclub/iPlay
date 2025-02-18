//
//  MCHostManager.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import Foundation
import MultipeerConnectivity


enum ViewState {
    case preLobby, inLobby, inGame
}
enum GameState {
    case Infected, Spectrum
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
    var infectedPlayers: [MCPeerID: Bool] = [:]

    var gameParticipants = Set<Player>()
    
    var viewState: ViewState = .preLobby
    var gameState: GameState = .Infected
    
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
                print("Received vector: \(vector_data)")
            case "spectrumPromptFromPrompter":
                let prompt = try mcData.decodeData(id: mcData.id, as: MCDataString.self)
                sendPrompt(data, peerID)
                
            //Add Additional Cases Here:
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
    
    //Sends the prompt to the other players
    func sendPrompt(_ promptData: Data, _ sender: MCPeerID) {
        guard let session else {
            print("Could not send prompt, no session active")
            return
        }
        
        do {
            let recipients = session.connectedPeers.filter { $0 != sender }
            try session.send(promptData, toPeers: recipients, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
    
    // Add other Multipeer Connectivity send functions here:
    
    func setPlayerInfected(_ player: MCPeerID) {
        if (infectedPlayers[player] != true) {
            infectedPlayers[player] = true
            print("\(player.displayName) is now infected!")
        }
    }
    
    func sendDataToInfectedPlayers(_ data: Data) {
        guard let session else {
            print("Could not send data, no session active")
            return
        }
        
        let infectedPeers = infectedPlayers.filter { (peerID, isInfected) in
            isInfected == true
        }.map { (peerID, _) in
            peerID
        }


        if infectedPeers.isEmpty {
            print("No infected players to send data to")
            return
        }

        do {
            try session.send(data, toPeers: infectedPeers, with: .reliable)
            print("Sent data to infected players: \(infectedPeers.map { $0.displayName })")
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }

}
