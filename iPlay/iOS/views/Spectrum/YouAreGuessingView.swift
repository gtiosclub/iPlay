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
                .foregroundStyle(.black)
            Text(prompt)
                .foregroundStyle(.black)
            Text("The prompt is: \(hint)")
                .foregroundStyle(.black)
            SpriteView(scene: scene)
                .frame(width: 400, height: 150)
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
            
            Spacer()
            
            Button("Guess") {
                playerManager.submitGuess(guess: scene.getGuess())
            }
            .buttonStyle(.borderedProminent)
            
            
            Spacer()
        }
    }
}

#endif
