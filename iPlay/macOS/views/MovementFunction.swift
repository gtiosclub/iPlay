//
//  MovementFunction.swift
//  iPlay
//
//  Created by Rexxwell Tendean on 2/11/25.
//

import SwiftUI
import SpriteKit

/// This view tests the movement of a ball using the Mac's keys.
struct ContentView: View {
    var scene: SKScene {
        let game = GameScene(size: CGSize(width: 500, height: 500))
        game.scaleMode = .aspectFill
        return game
    }
    
    var body: some View {
        SpriteView(scene: scene)
    }
}

#Preview {
    ContentView()
}
