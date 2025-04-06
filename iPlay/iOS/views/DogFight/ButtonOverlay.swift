//
//  ButtonOverlay.swift
//  iPlay
//
//  Created by Jack Seal on 3/25/25.
//

import SwiftUI

struct ButtonOverlay: View {
    var onPress: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            Image("dogFightButtonRim")
                .resizable()
                .scaledToFit()
                .frame(width: 260, height: 260)
            Button(action: {
                isPressed = true
                onPress()
                DispatchQueue.main.asyncAfter(deadline:.now() + 2)
                {isPressed = false}
            }, label: {
                Image(isPressed ? "pressedDogFightButton" : "unpressedDogFightButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .offset(y: 2)
            })
            .disabled(isPressed)
            .buttonStyle(PlainButtonStyle())
            
//            Image(isPressed ? "pressedDogFightButton" : "unpressedDogFightButton")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 200, height: 200)
//                .offset(y: 2)
//                .gesture(
//                    DragGesture(minimumDistance: 0)
//                        .onChanged { _ in
//                            if !isCoolingDown {
//                                isPressed = true
//                            }
//                        }
//                        .onEnded { _ in
//                            isCoolingDown = true
//                            onPress()
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                isPressed = false
//                                isCoolingDown = false
//                            }
//                        }
//                )
        }
    }
}
#Preview {
    ButtonOverlay(onPress: {})
}
