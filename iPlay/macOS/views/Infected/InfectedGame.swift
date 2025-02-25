//
//  InfectedGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/6/25.
//

import SpriteKit

class InfectedGame: SKScene {
    override func didMove(to: SKView) {
        self.backgroundColor = .gray
        generateObstacles()
        generatePlayerNodes()
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
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
    
    enum ShapeType: CaseIterable {
        case circle, rectangle
    }
    
    func generateObstacles() {
        let numberOfObstacles = Int.random(in: 4...7)
        
        for _ in 0..<numberOfObstacles {
            let shape = ShapeType.allCases.randomElement()!
            var position: CGPoint
            
            //Random Shape Selection
            let obstacle: SKShapeNode
            switch shape {
            case .circle: obstacle = SKShapeNode(circleOfRadius: CGFloat.random(in: 40...100))
            case .rectangle: obstacle = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 70...200), height: CGFloat.random(in: 70...200)))
                //T0-DO: generate obstacles of more shapes, polygons using CGMutablePath
            }
            //Select future position for obstacle
            repeat {
                position = CGPoint(
                    x: CGFloat.random(in: 50...(frame.width - 50)),
                    y: CGFloat.random(in: 50...(frame.height - 50))
                )
            } while isTooClose(position)
            obstacle.position = position
            //Color and Outline
            obstacle.fillColor = SKColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
            obstacle.strokeColor = .black
            //Rotation
            obstacle.zRotation += .pi * CGFloat.random(in: 0..<2)
            //Physics Collision
            obstacle.physicsBody = SKPhysicsBody(edgeLoopFrom: obstacle.path!)
            obstacle.physicsBody?.affectedByGravity = false
            obstacle.physicsBody?.allowsRotation = false
            obstacle.physicsBody?.collisionBitMask = 0x1
            addChild(obstacle)
        }
    }
    
    //Check if Obstacle will be spawned too close to obstacles & players
    func isTooClose(_ position: CGPoint) -> Bool {
        for obstacle in children {
            let dx = position.x - obstacle.position.x
            let dy = position.y - obstacle.position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance < 200 {
                return true
            }
        }
        return false
    }
    
    
    func generatePlayerNodes() {
        let spawnPoints: [CGPoint] = generateSpawnPoints(MCHostManager.shared!.infectedPlayers.count)

        for i in MCHostManager.shared!.infectedPlayers.indices {
            let player = MCHostManager.shared!.infectedPlayers[i]
            player.playerObject.position = spawnPoints[i]
            (player.playerObject as! SKShapeNode).fillColor = player.isInfected ? .red : .green // only if player node is shape
            let name = SKLabelNode(fontNamed: "SF Compact")
            name.text = player.name
            name.fontSize = 12
            name.position = CGPoint(x: 0, y: 16)
            player.playerObject.addChild(name)
            //Physics bodies set up for collision
            //TO-DO: update the physics body shapes once we get the sprites implemented to
            player.playerObject.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            player.playerObject.physicsBody?.affectedByGravity = false
            player.playerObject.physicsBody?.allowsRotation = false
            player.playerObject.physicsBody?.collisionBitMask = 0x1
            addChild(player.playerObject)
            
        }
    }
    
    func generateSpawnPoints(_ numPlayers: Int) -> [CGPoint] {
        var spawnPoints: [CGPoint] = []
        let w = self.frame.width
        let h = self.frame.height
        let xMargin = w * 0.05
        let yMargin = h * 0.05
        let cornerMargin = w * 0.1
        let xMidPoint = w / 2
        let yMidPoint = h / 2
        
        for i in 0...(numPlayers - 1) {
            var spawnPoint: CGPoint
            switch i {
            case 0: spawnPoint = CGPoint(x: CGFloat.random(in: cornerMargin...(xMidPoint - xMargin)), y: h - yMargin)
            case 1: spawnPoint = CGPoint(x: CGFloat.random(in: (xMidPoint + xMargin)...(w - cornerMargin)), y: yMargin)
            case 2: spawnPoint = CGPoint(x: w - xMargin, y: CGFloat.random(in: (yMidPoint + yMargin)...(h - yMargin)))
            case 3: spawnPoint = CGPoint(x: xMargin, y: CGFloat.random(in: cornerMargin...(yMidPoint - yMargin)))
            case 4: spawnPoint = CGPoint(x: CGFloat.random(in: (xMidPoint + xMargin)...(w - cornerMargin)), y: h - yMargin)
            case 5: spawnPoint = CGPoint(x: CGFloat.random(in: cornerMargin...(xMidPoint - xMargin)), y: yMargin)
            case 6: spawnPoint = CGPoint(x: w - xMargin, y: CGFloat.random(in: cornerMargin...(yMidPoint - yMargin)))
            default: spawnPoint = CGPoint(x: xMargin, y: CGFloat.random(in: (yMidPoint + yMargin)...(h - yMargin)))
            }
            spawnPoints.append(spawnPoint)
        }
        return spawnPoints
    }
    
    func infect(_ player: inout InfectedPlayer) {
        player.isInfected = true
        (player.playerObject as! SKShapeNode).fillColor = player.isInfected ? .red : .green
    }
}

