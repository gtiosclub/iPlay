//
//  YouAreGuessingView.swift
//  iPlay
//
//  Created by Danny Byrd on 2/25/25.
//

import SwiftUI
import SpriteKit

struct YouAreGuessingView: View {
    var scene: SKScene {
        let scene = ArrowComponent(size: CGSize(width: 400, height: 150))
        scene.scaleMode = .resizeFill
        return scene
    }
    
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("You are guessing!")
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
                
            }
            .buttonStyle(.borderedProminent)
            
            
            Spacer()
        }
    }
}

#Preview {
    YouAreGuessingView()
}
