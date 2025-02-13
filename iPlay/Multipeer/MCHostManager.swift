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

/*
 MC Host Manager is the class containing the attributes and functions dictating the multipeer connectivity on the side of the Mac/Host
 */
@Observable
class MCHostManager: NSObject {
    static var shared: MCHostManager?
    
    let serviceType = "iPlay"
    var advertiser: MCNearbyServiceAdvertiser
    var session: MCSession?
    var peer: MCPeerID
    
    var gameParticipants = Set<Player>()
    
    var viewState: ViewState = .preLobby
    
    private init(name: String) {
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
    
    /*
     Sends the prompt to the other players
     */
    func sendPrompt(_ prompt: String, _ sender: MCPeerID) {
        do {
            if let data = prompt.data(using: .utf8){
                let recipients = session?.connectedPeers.filter { $0 != sender } ?? []
                try session?.send(data, toPeers: recipients, with: .reliable)
                print("SENT: \(prompt)")
            }
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
}

extension MCHostManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        //TODO: Fill in for changing session state
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let receivedString = String(data: data, encoding: .utf8) {
            print("Received: \(receivedString) from \(peerID)")
            sendPrompt(receivedString, peerID)
        } else {
            print("Error: Received invalid prompter word")
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
