//
//  DogFightPlayer.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

let planeSprites = ["PlaneBlank", "PlaneRed", "PlaneGreen", "PlaneBlue"]
struct DogFightPlayer: Hashable, Identifiable {
    var id: MCPeerID = MCPeerID(displayName: "default")
    var name: String = "name"
    var isHit: Bool = false
    var lives: Int = 3
    var playerObject: SKSpriteNode
    let vectorMagnitude: Double = 110.0 //Constant velocity that planes fly, they only change direction for now
    var heading: Vector = Vector(x:0,y:1) //Normalized vector where plane is currently pointing (magnitude should be 1)
    var avatar: String
    let turnSpeed: Double = 1.0
    
    //TO-DO: create function to update heading vectors
    
    mutating func updateHeading(by inputAngle: MCDataFloat) {
        //Input heading from gyro should be in range - 1/2 pi to 1/2 pi,
        let turnAngle = inputAngle.num * turnSpeed / 60.0
        let angleHeading = atan2(heading.y, heading.x)
        let newHeading = angleHeading - turnAngle
        heading = Vector(x: cos(newHeading), y: sin(newHeading))
    }

}
