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
    var dogFightPlayers: [DogFightPlayer] = [DogFightPlayer(avatar: "BottleSprite"), DogFightPlayer(avatar: "FlaskSprite")]
    
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
                    ForEach(dogFightPlayers) { player in
                        ZStack(alignment: .bottomTrailing) {
                            Image(player.avatar)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                            Text("x\(player.lives)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(4)
                                .background(Color.clear)
                                .cornerRadius(4)
                                .offset(x: 5, y: -4)
                        }
                        .offset(y:-10)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    DogFight(mcManager: MCHostManager(name: "TEST"))
}
