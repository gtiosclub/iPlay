//
//  DogFight.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

import SwiftUI
import SpriteKit

struct DogFight: View {
    @ObservedObject var mcManager: MCHostManager
    
    var scene : SKScene {
        let scene = DogFightGame()
        scene.size = CGSize(width:1280, height:800)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
        }
    }
}

#Preview {
    DogFight(mcManager: MCHostManager(name: "TEST"))
}
