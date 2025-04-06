//
//  DogFightGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

//#if os(macOS)
import SpriteKit

class DogFightGame: SKScene {
    override func didMove(to: SKView) {
        //Add background
        #if os(macOS)
        let texture = SKTexture(image: NSImage(named: "DogFightBackground")!)
        let background = SKSpriteNode(texture: texture)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = self.size
        addChild(background)
        #endif
        
        generateDogFightPlayerNodes()
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //Move players in direction of heading
        for player in MCHostManager.shared!.dogFightPlayers {
            // Smoothly interpolate between current heading and desired heading
            let currentHeading = player.playerObject.zRotation
            let targetHeading = atan2(player.heading.y, player.heading.x)
            
            let interpolationFactor: CGFloat = 0.1  // Interpolate angle with easing (adjust factor for smoothness)
            let smoothedHeading = interpolateAngle(from: currentHeading, to: targetHeading, factor: interpolationFactor)
            
            player.playerObject.zRotation = smoothedHeading

            // Move in direction of current zRotation (based on smooth heading)
            let dx = CGFloat(cos(Double(smoothedHeading))) * player.vectorMagnitude / 60
            let dy = CGFloat(sin(Double(smoothedHeading))) * player.vectorMagnitude / 60
            player.playerObject.position.x += dx
            player.playerObject.position.y += dy
        }
        print("Balls: \(MCHostManager.shared!.dogFightBalls)")
        for i in MCHostManager.shared!.dogFightBalls.indices {
            let ball = MCHostManager.shared!.dogFightBalls[i]
            
            if ball.sprite == nil { //new ball, need to create sprite
//                print("BEFORE ball.sprite: \(ball.sprite ?? SKSpriteNode())")
                MCHostManager.shared!.dogFightBalls[i].sprite = spawnBall(ball: ball)
//                print("AFTER  ball.sprite: \(ball.sprite ?? SKSpriteNode())")
            } else {
                MCHostManager.shared!.dogFightBalls[i].sprite!.position.x += ball.velocity.dx / 60
                MCHostManager.shared!.dogFightBalls[i].sprite!.position.y += ball.velocity.dy / 60
            }
        }
    }
    
    func interpolateAngle(from: CGFloat, to: CGFloat, factor: CGFloat) -> CGFloat {
        var delta = to - from
        if delta > .pi {
            delta -= 2 * .pi
        } else if delta < -.pi {
            delta += 2 * .pi
        }
        return from + delta * factor
    }
    
    func spawnBall(ball: DogFightBall) -> SKSpriteNode {
        let ballSprite = SKSpriteNode(imageNamed: "PaperBall")
        ballSprite.size = CGSize(width:60, height: 57)
        ballSprite.position = ball.position

        ballSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 30, height: 30))
        ballSprite.physicsBody?.affectedByGravity = false
        ballSprite.physicsBody?.isDynamic = true
        ballSprite.physicsBody?.allowsRotation = false
        ballSprite.physicsBody?.collisionBitMask = 0x2
        addChild(ballSprite)
        return ballSprite
    }
    
    func generateDogFightPlayerNodes() {
        let spawnPoints: [CGPoint] = generateSpawnPoints(MCHostManager.shared!.dogFightPlayers.count)

        for i in MCHostManager.shared!.dogFightPlayers.indices {
            let playerObject = MCHostManager.shared!.dogFightPlayers[i].playerObject
            playerObject.position = spawnPoints[i]
            playerObject.size = CGSize(width: 103, height: 41)
            
            //Update heading
            let dx = (size.width / 2)  - playerObject.position.x
            let dy = (size.height / 2) - playerObject.position.y
            var length = sqrt(dx*dx + dy*dy)
            if  length == 0 {
                length = 1
            }
            let heading = Vector(x: dx / length, y: dy / length)
            
            //Make playernode rotate to match heading
            playerObject.zRotation = atan2(heading.y, heading.x)
            MCHostManager.shared!.dogFightPlayers[i].heading = heading
            //Physics bodies set up for collision
            playerObject.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 30))
            playerObject.physicsBody?.affectedByGravity = false
            playerObject.physicsBody?.isDynamic = true
            playerObject.physicsBody?.allowsRotation = false
            playerObject.physicsBody?.collisionBitMask = 0x1
            
            addChild(playerObject)
            
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
    
    func shootBall() {
        
    }
}

