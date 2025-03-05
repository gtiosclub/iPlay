//
//  InfectedPlayer.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/18/25.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

struct InfectedPlayer: Hashable, Identifiable {
    var id: MCPeerID = MCPeerID(displayName: "default")
    var name: String = "name"
    var isInfected: Bool = false
    var points: Int = 0
    var playerObject: SKNode = SKShapeNode(circleOfRadius: 10)
    let MOVEMULTIPLIER: CGFloat = 20
    
    func move(by vector: Vector) {
        // infected player should move faster (or he will never catch)
        let x = vector.x * MOVEMULTIPLIER * (isInfected ? 1.3 : 1)
        let y = -vector.y * MOVEMULTIPLIER * (isInfected ? 1.3 : 1)
        playerObject.run(SKAction.moveBy(x: x, y: y, duration: 1))
    }
}
