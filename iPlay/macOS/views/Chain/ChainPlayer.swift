//
//  ChainPlayer.swift
//  iPlay
//
//  Created by Josheev Rai on 4/8/25.
//

import Foundation
import MultipeerConnectivity

struct ChainPlayer: Hashable, Identifiable {
    var id: MCPeerID = MCPeerID(displayName: "default")
    var name: String = "name"
    var points: Int = 0
    var chain: [String] = []
}

struct ChainCompletion: Codable, Equatable {
    let position: Int
    let totalPlayers: Int
    
    static func == (lhs: ChainCompletion, rhs: ChainCompletion) -> Bool {
        return lhs.position == rhs.position && lhs.totalPlayers == rhs.totalPlayers
    }
}
