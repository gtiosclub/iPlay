//
//  ButtonOverlay.swift
//  iPlay
//
//  Created by Jack Seal on 3/25/25.
//

import SwiftUI

struct ButtonOverlay: View {
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Image("dogFightButtonRim")
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)
            Image(isPressed ? "pressedDogFightButton" : "unpressedDogFightButton")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .offset(y: 2)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isPressed = true
                        }
                        .onEnded { _ in
                            isPressed = false
                        }
                )
        }
    }
}
#Preview {
    ButtonOverlay()
}
