//
//  Player.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import SwiftUI
import Foundation
import MultipeerConnectivity

let avatars: [String] = ["BarrelSprite", "BlenderSprite", "BottleSprite", "BowlSprite", "CeramicCupSprite", "FlaskSprite", "GasCanSprite", "GraterSprite", "KettleSprite", "MilkCartonSprite", "MugSprite", "PiperSprite", "PlantPotSprite", "SaltShakerSprite"]

struct Player: Hashable, Identifiable {
    //TODO: Add More Attributes: Avatar, ...
    var id: MCPeerID
    var username: String
    var avatar: String
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
        self.avatar = avatars.randomElement()!
        self.points = 0
    }
    init(id: MCPeerID, username: String, avatar: String, points: Int) {
        self.id = id
        self.username = username
        self.avatar = avatars.randomElement()!
        self.points = points
    }
}
