//
//  DogFightPlayer.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

#if os(macOS)
let planeSprites = [
    "PlaneBlank": NSColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0),
    "PlaneRed": NSColor(red: 219/255, green: 20/255, blue: 20/255, alpha: 1.0),
    "PlaneGreen": NSColor(red: 91/255, green: 138/255, blue: 62/255, alpha: 1.0),
    "PlaneBlue": NSColor(red: 36/255, green: 110/255, blue: 185/255, alpha: 1.0),
    "PlanePink": NSColor(red: 254/255, green: 116/255, blue: 183/255, alpha: 1.0),
    "PlaneYellow": NSColor(red: 255/255, green: 228/255, blue: 110/255, alpha: 1.0), 
    "PlaneSalmon": NSColor(red: 241/255, green: 171/255, blue: 134/255, alpha: 1.0)]
#endif

struct DogFightPlayer: Hashable, Identifiable {
    var id: MCPeerID = MCPeerID(displayName: "default")
    var name: String = "name"
    var isHit: Bool = false
    var lives: Int = 3
    var playerObject: SKSpriteNode
    let vectorMagnitude: Double = 110.0 //Constant velocity that planes fly, they only change direction for now
    var heading: Vector = Vector(x:0,y:1) //Normalized vector where plane is currently pointing (magnitude should be 1)
    var avatar: String
    var planeName: String // used for restoring plane sprite after being hit
    let turnSpeed: Double = 1.0
    #if os(macOS)
    let color: NSColor
    #endif
    var points: Int = 0
    
    //TO-DO: create function to update heading vectors
    
    mutating func updateHeading(by inputAngle: MCDataFloat) {
        //Input heading from gyro should be in range - 1/2 pi to 1/2 pi,
        let turnAngle = inputAngle.num * turnSpeed / 60.0
        let angleHeading = atan2(heading.y, heading.x)
        let newHeading = angleHeading - turnAngle
        heading = Vector(x: cos(newHeading), y: sin(newHeading))
    }

}
