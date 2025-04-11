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
        scene.backgroundColor = .clear
        return scene
    }
    
    var body: some View {
        ZStack {
            
            SpriteView(scene: scene)
                .ignoresSafeArea()
            

            VStack {
                HStack(spacing: 8) {
                    #if os(macOS)
                    ForEach(MCHostManager.shared!.dogFightPlayers, id: \.id) { player in
                        ZStack(alignment: .bottomTrailing) {
                            Image(player.avatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75, height: 75)

                            Text("x\(player.lives)")
                                .font(.system(size: 22))
                                .fontWeight(.bold)
                                .foregroundColor(Color(player.color))
                                .padding(4)
                                .offset(x: 20, y: -15)
                        }
                        .offset(y:-10)
                    }
                    #endif
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    DogFight(mcManager: MCHostManager(name: "test"))
}
