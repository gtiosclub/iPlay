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
    var host: MCPeerID?
    var openLobbies = Set<Lobby>()
    
    var viewState = ViewState.preLobby
    
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
            host = peerID
            viewState = .inLobby
        @unknown default:
            print("Unknown State")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        //TODO: Fill in for recieving data
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
