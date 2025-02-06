//
//  Lobby.swift
//  iPlay
//
//  Created by Danny Byrd on 2/6/25.
//

import Foundation
import MultipeerConnectivity

struct Lobby: Hashable, Identifiable {
    //TODO: Add More Attributes: Lobby Type, ...
    var id: MCPeerID
    
    static func ==(a: Lobby, b: Lobby) -> Bool {
        a.id == b.id
    }
}
