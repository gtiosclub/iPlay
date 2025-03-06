//
//  YouAreGuessingView.swift
//  iPlay
//
//  Created by Danny Byrd on 2/25/25.
//

#if os(iOS)
import SwiftUI
import SpriteKit

struct YouAreGuessingView: View {
    var scene: ArrowComponent {
        let scene = ArrowComponent(size: CGSize(width: 400, height: 150))
        scene.scaleMode = .resizeFill
        return scene
    }
    var hint: String
    var prompt: String
    @Binding var playerManager: MCPlayerManager!
    
    var body: some View {
        VStack {
            Spacer()
            Text("You are guessing!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Text(prompt)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            SpriteView(scene: scene, options: .allowsTransparency)
                .frame(width: 300, height: 120)
                .background(Color.clear)

            HStack {
                Spacer()
                Text("0")
                    .bold()
                Spacer()
                Spacer()
                Text("10")
                    .bold()
                Spacer()
            }
            
            Text("The prompt is: \(hint)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
            
            Spacer()
            
            Button("Guess") {
                print("Guess: \(ArrowComponent.guess)")
                playerManager.submitGuess(guess: ArrowComponent.guess)
            }
            .buttonStyle(.borderedProminent)
            
            
            Spacer()
        }
    }
}

#endif
