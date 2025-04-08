//
//  DogFightGame.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

import SpriteKit

class DogFightGame: SKScene {
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "dogfightbg")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = -100 // make sure it's behind everything else
        let planeOne = SKSpriteNode(imageNamed: "plane1")
        planeOne.size = CGSize(width: 100, height: 60 )
        planeOne.position = CGPoint(x: 200, y: 400)
        let planeTwo = SKSpriteNode(imageNamed: "plane2")
        planeTwo.size = CGSize(width: 100, height: 60 )
        planeTwo.position = CGPoint(x: 1000, y: 400)
        let planeThree = SKSpriteNode(imageNamed: "plane3")
        planeThree.size = CGSize(width: 100, height: 60 )
        planeThree.position = CGPoint(x: 800, y: 200)
        planeThree.zRotation = -CGFloat.pi / 8
        [background,planeOne,planeTwo,planeThree] .forEach { addChild($0) }

        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
