//
//  Player.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import SwiftUI
import Foundation
import MultipeerConnectivity

struct Player: Hashable, Identifiable {
    //TODO: Add More Attributes: Avatar, ...
    var id: MCPeerID
    var username: String
    var avatar: Image
    var points: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.displayName)
    }
    
    static func ==(a: Player, b: Player) -> Bool {
        a.id == b.id
    }
    init(id: MCPeerID) {
        self.id = id
        self.username = id.displayName
        self.avatar = Image("defaultAvatar")
        self.points = 0
    }
    init(id: MCPeerID, username: String, avatar: Image, points: Int) {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.points = points
    }
}
