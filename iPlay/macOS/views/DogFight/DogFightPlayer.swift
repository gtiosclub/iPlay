//
//  DogFightPlayer.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

struct DogFightPlayer: Hashable, Identifiable {
    var id: MCPeerID = MCPeerID(displayName: "default")
    var name: String = "name"
    var hasBall: Bool = true
    var lives: Int = 3
    var playerObject: SKNode = SKShapeNode(circleOfRadius: 10)
    let vectorMagnitude: Double = 20.0 //Constant velocity that planes fly, they only change direction for now
    var heading: Vector = Vector(x:0,y:1) //Normalized vector where plane is currently pointing (magnitude should be 1)
    
    //TO-DO: create function to update heading vectors
    
    func move() {
        let x = heading.x
        let y = -heading.y
        playerObject.run(SKAction.moveBy(x: x, y: y, duration: 1))
    }

}
