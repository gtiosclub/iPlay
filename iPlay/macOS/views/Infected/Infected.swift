//
//  Infected.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/6/25.
//

import SwiftUI
import SpriteKit

struct Infected: View {
    @ObservedObject var mcManager: MCHostManager
    
    var scene : SKScene {
        let scene = InfectedGame()
        scene.size = CGSize(width:1280, height:800)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
            VStack(alignment: .center) {
                TimerView()
                Spacer()
                ScoreTracking(players: Array(mcManager.gameParticipants))
            }
        }
    }
}

#Preview {
    Infected(mcManager: MCHostManager(name: "TEST"))
}
