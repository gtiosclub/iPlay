//
//  InfectedGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/6/25.
//

import SpriteKit

class InfectedGame: SKScene {
    override func didMove(to: SKView) {

        self.backgroundColor = SKColor(red:255.0/255, green:235.0/255,blue:205.0/255,alpha:1.0)
        generatePlayerNodes()
        generateObstacles()
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
    }
    override func update(_ currentTime: TimeInterval) {
        guard let MCManager = MCHostManager.shared else { return }
        
        for infectorIndex in MCManager.infectedPlayers.indices where MCManager.infectedPlayers[infectorIndex].isInfected{
            let infector = MCManager.infectedPlayers[infectorIndex]
            
            for infectedIndex in MCManager.infectedPlayers.indices where infectedIndex != infectorIndex {
                let infected = MCManager.infectedPlayers[infectedIndex]
                
                let dx = infector.playerObject.position.x - infected.playerObject.position.x
                let dy = infector.playerObject.position.y - infected.playerObject.position.y
                
//               if sqrt(dx * dx + dy * dy) < 50 && infector.name != infected.name {
                if infector.playerObject.intersects(infected.playerObject) && infector.name != infected.name {
                    print("detected collision")
                    infect(infectedIndex, infectorIndex: infectorIndex)
                }
            }
        }
        
        if MCManager.secondsElapsed >= 60 {
            print("ENDING INFECTED: time ran out")
            MCManager.endInfectedGame()
        }
    }
    
    enum ShapeType: CaseIterable {
        case circle, rectangle, polygon
    }
    
    func generateObstacles() {
        let numberOfObstacles = Int.random(in: 6...8)
        
        for _ in 0..<numberOfObstacles {
            let shape = ShapeType.allCases.randomElement()! // Gets random shape from ShapeType
            var position: CGPoint
            
            //Random Shape Selection
            let obstacle: SKShapeNode
            switch shape {
            case .circle: obstacle = SKShapeNode(circleOfRadius: CGFloat.random(in: 70...100))
            case .rectangle: obstacle = SKShapeNode(rectOf: CGSize(width: CGFloat.random(in: 120...200), height: CGFloat.random(in: 140...200)))
                //T0-DO: generate obstacles of more shapes, polygons using CGMutablePath
            case .polygon: obstacle = SKShapeNode(path: polygonPath(sides: Int.random(in: 5...8), x: CGFloat.random(in: 50...(frame.width - 50)), y: CGFloat.random(in: 50...(frame.height - 50)), offset: 0))
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
//            obstacle.fillColor = SKColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
            let colorOptions = [
                SKColor(red: 171.0/255, green:206.0/255, blue:149.0/255, alpha:1.0), //Green
                SKColor(red: 175/255.0, green: 218/255.0, blue: 218/255.0, alpha:1.0), // Blue
                SKColor(red: 248/255.0, green: 180/255.0, blue: 182/255.0, alpha:1.0), //red
                SKColor(red: 218/255.0, green: 191/255.0, blue: 150/255.0, alpha:1.0) //brown
            ]
            
            obstacle.fillColor = colorOptions.randomElement()!
            obstacle.strokeColor = .black
            obstacle.lineWidth = 5
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
    
    /**
     Creates the points of the polygon.
     - Parameters:
        - sides: The number of sides of the polygon
        - x: The x-coordinate of the center of the polygon
        - y: The y-coordinate of the center of the polygon
        - radius: The radius of the polygon
        - offset: Change where a view is drawn
     - Returns: An array of the points of the polygon.
     */
    func polygonPointArray(sides: Int, x: CGFloat, y: CGFloat, offset: CGFloat) -> [CGPoint] {
        let angle = (360/CGFloat(sides)).radians() // .radians() is a function created in the extension of CGFloat
        let cx = x // x origin
        let cy = y // y origin
        var i = 0
        var points = [CGPoint]()
        while i <= sides {
            let r = CGFloat.random(in: 40...100)
            let xpo = cx + r * cos(angle * CGFloat(i) - offset.radians()) // parametric equation of a circle
            let ypo = cy + r * sin(angle * CGFloat(i) - offset.radians()) // parametric equation of a circle
            points.append(CGPoint(x: xpo, y: ypo))
            i += 1
        }
        return points
    }
    
    //Creates path for a polygon
    func polygonPath(sides: Int, x: CGFloat, y: CGFloat, offset: CGFloat) -> CGPath {
        let path = CGMutablePath.init()
        let points = polygonPointArray(sides: sides, x: x, y: y, offset: offset)
        let cpg = points[0]
        path.move(to: CGPoint(x: cpg.x, y: cpg.y))
        for point in points {
            path.addLine(to: CGPoint(x: point.x, y: point.y))
        }
        path.closeSubpath()
        return path
    }
    
    //Check if Obstacle will be spawned too close to obstacles & players
    func isTooClose(_ position: CGPoint) -> Bool {
        for obstacle in children {
            let dx = position.x - obstacle.position.x
            let dy = position.y - obstacle.position.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance < 300 {
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
            player.playerObject.size = CGSize(width: 80, height: 80)
            let name = SKLabelNode(fontNamed: "SF Compact")
            name.text = player.name
            name.fontSize = 15
            name.position = CGPoint(x: 0, y: 40)
            name.name = "name"
            name.fontColor = (player.isInfected ? .red : .white)
            name.physicsBody = nil
            player.playerObject.addChild(name)
            //Physics bodies set up for collision
//            player.playerObject.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
            player.playerObject.physicsBody = SKPhysicsBody(texture: player.playerObject.texture!, size: player.playerObject.size)
            player.playerObject.physicsBody?.affectedByGravity = false
            player.playerObject.physicsBody?.isDynamic = true
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
    
    func infect(_ infectedIndex: Int, infectorIndex: Int) {
        guard let mcManager = MCHostManager.shared else { return }

        if !mcManager.infectedPlayers[infectedIndex].isInfected {
            mcManager.infectScore(infectorIndex: infectorIndex, infectedIndex: infectedIndex)
            (mcManager.infectedPlayers[infectedIndex].playerObject.childNode(withName: "name") as! SKLabelNode).fontColor = .red
            let infectedState = MCInfectedState(infected: true, playerID: mcManager.infectedPlayers[infectedIndex].id.displayName)
            mcManager.sendInfectedState(infectedState)
            mcManager.numInfected += 1  // Increment the count of infected players
            if mcManager.numInfected == mcManager.infectedPlayers.count - 1 {
                print("ENDING INFECTED: everyone is infected")
                mcManager.endInfectedGame()
            }
            
        }
        
    }

}

extension CGFloat {
    
    /// Converts an angle in degrees to radians.
    /// - Returns: An angle in radians.
    func radians() -> CGFloat {
        let rad = CGFloat(Double.pi) * (self/180)
        return rad
    }
}
