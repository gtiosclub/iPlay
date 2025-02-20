//
//  InfectedGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/6/25.
//

import SpriteKit

class InfectedGame: SKScene {
    override func didMove(to: SKView) {
        self.backgroundColor = .blue
        generateObstacles()
        generatePlayerNodes()
        
        
    }
    
    func generateObstacles() {
//        let obstacle = SKShapeNode(rectOf: CGSize(width: 50, height: 100))
//        obstacle.position = CGPoint(x: 100, y: 100)
//        obstacle.fillColor = .green
//        addChild(obstacle)
    }
    func generatePlayerNodes() {
        for player in MCHostManager.shared!.infectedPlayers {
            player.playerObject.position = CGPoint(x: 200, y: 200)
            (player.playerObject as! SKShapeNode).fillColor = player.isInfected ? .red : .green // only if player node is shape
            let name = SKLabelNode(fontNamed: "SF Compact")
            name.text = player.name
            name.fontSize = 12
            name.position = CGPoint(x: 0, y: 16)
            player.playerObject.addChild(name)
            addChild(player.playerObject)
            
        }
    }
}

