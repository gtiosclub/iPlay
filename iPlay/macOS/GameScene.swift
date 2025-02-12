//
//  GameScene.swift
//  iPlay
//
//  Created by Rexxwell Tendean on 2/12/25.
//

import SpriteKit
import Foundation

/**
 This class represents the GameScene class which overrides all the necessary
 functions to make the ball move with the keyboard in the MovementFunction.swift view.
 */
class GameScene: SKScene {
    /// Ball object that we are going to move.
    let ball: SKShapeNode = SKShapeNode(circleOfRadius: 10)
    
    /**
     Implement any custom behavior for your scene when it is about to be presented by a view.
     
     - Parameters:
        - view: The view that is presenting the scene.
     */
    override func didMove(to view: SKView) {
        backgroundColor = .blue
        ball.fillColor = .red
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(ball)
    }
    
    /**
     Informs the view that the user has pressed the key. If a user presses a certain key, do a certain action.
     
     - Parameters:
        - event: An object encapsulating information about the key-down event.
     */
    override func keyDown(with event: NSEvent) {
        if event.specialKey == .upArrow {
            moveByVector(vector: Vector(x: 0, y: 10))
        }
        if event.specialKey == .downArrow {
            moveByVector(vector: Vector(x: 0, y: -10))
        }
        if event.specialKey == .leftArrow {
            moveByVector(vector: Vector(x: -10, y: 0))
        }
        if event.specialKey == .rightArrow {
            moveByVector(vector: Vector(x: 10, y: 0))
        }
    }
    
    /**
     Tells your app to perform any app-specific logic to update your scene. It is called by the system once per frame,
     so long as the scene is presented in a view and is not paused. This method will be called first when animating a scene,
     before any actions are evaluated and before any physics are simulated.
     
     In this case, we set the velocity of the ball to be constant even when you press and hold a key to make the ball move right.
     
     - Parameters:
        - currentTime: The current system time
     */
    override func update(_ currentTime: CFTimeInterval) {
        ball.physicsBody?.velocity = CGVectorMake(200, 200);
    }
    
    /**
     Adds an action to the list of actions executed by the ball. In this case, the ball should go up, down, left, and right.
     
     - Parameters:
        - vector: Vector that represents the direction and distance the ball should go.
     */
    func moveByVector(vector: Vector) {
        ball.run(SKAction.moveBy(x: vector.x, y: vector.y, duration: 1))
    }
}
