//
//  Player.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import Foundation
import MultipeerConnectivity

struct Player: Hashable, Identifiable {
    //TODO: Add More Attributes: Avatar, ...
    var id: MCPeerID
    
    static func ==(a: Player, b: Player) -> Bool {
        a.id == b.id
    }
}
