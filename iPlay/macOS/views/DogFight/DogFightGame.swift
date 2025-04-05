//
//  DogFightGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

#if os(macOS)
import SpriteKit

class DogFightGame: SKScene {
    override func didMove(to: SKView) {
        //Add background
        let texture = SKTexture(image: NSImage(named: "DogFightBackground")!)
        let background = SKSpriteNode(texture: texture)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        background.size = self.size
        addChild(background)
        
        generateDogFightPlayerNodes()
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func generateDogFightPlayerNodes() {
        let spawnPoints: [CGPoint] = generateSpawnPoints(MCHostManager.shared!.dogFightPlayers.count)

        for i in MCHostManager.shared!.dogFightPlayers.indices {
            let player = MCHostManager.shared!.dogFightPlayers[i]
            player.playerObject.position = spawnPoints[i]
            player.playerObject.size = CGSize(width: 103, height: 41)

            //Physics bodies set up for collision
            player.playerObject.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 30))
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
}
#endif
