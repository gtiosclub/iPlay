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
    override func update(_ currentTime: TimeInterval) {
        for player in MCHostManager.shared!.infectedPlayers.filter({$0.isInfected}) {
            print("checking \(player.name)")
            for i in MCHostManager.shared!.infectedPlayers.indices {
                if player.playerObject.intersects(MCHostManager.shared!.infectedPlayers[i].playerObject) && player.name != MCHostManager.shared!.infectedPlayers[i].name {
                    print("detected collision")
                    infect(&MCHostManager.shared!.infectedPlayers[i])
                }
            }
            
        }
    }
    
    func generateObstacles() {
//        let obstacle = SKShapeNode(rectOf: CGSize(width: 50, height: 100))
//        obstacle.position = CGPoint(x: 100, y: 100)
//        obstacle.fillColor = .green
//        addChild(obstacle)
    }
    func generatePlayerNodes() {
        for player in MCHostManager.shared!.infectedPlayers {
            player.playerObject.position = CGPoint(x: Int.random(in: 200...400), y: Int.random(in: 200...400))
            (player.playerObject as! SKShapeNode).fillColor = player.isInfected ? .red : .green // only if player node is shape
            let name = SKLabelNode(fontNamed: "SF Compact")
            name.text = player.name
            name.fontSize = 12
            name.position = CGPoint(x: 0, y: 16)
            player.playerObject.addChild(name)
            addChild(player.playerObject)
            
        }
    }
    func infect(_ player: inout InfectedPlayer) {
        player.isInfected = true
        (player.playerObject as! SKShapeNode).fillColor = player.isInfected ? .red : .green
    }
}

