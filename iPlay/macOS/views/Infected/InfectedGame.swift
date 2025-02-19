//
//  InfectedGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/6/25.
//

import SpriteKit

class InfectedGame: SKScene {
    let player = SKShapeNode(circleOfRadius: 50)
    override func didMove(to: SKView) {
        self.backgroundColor = .blue
        generateObstacles()
        
        
    }
    
    func generateObstacles() {
//        let obstacle = SKShapeNode(rectOf: CGSize(width: 50, height: 100))
//        obstacle.position = CGPoint(x: 100, y: 100)
//        obstacle.fillColor = .green
//        addChild(obstacle)
    }
}

