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
