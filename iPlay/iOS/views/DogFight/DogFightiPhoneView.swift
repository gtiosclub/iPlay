//
//  DogFightiPhoneView.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//

import SwiftUI

struct DogFightiPhoneView: View {
    @State private var countdownStep = 3
    @State private var showCountdown = true
    @State private var wasHit = false
    let countdownInterval = 1.0
    
    var body: some View {
        ZStack {
            Image("dogFightPhoneBack")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if showCountdown {
                Image("countdown\(countdownStep)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .onAppear {
                        startCountdown()
                    }
            } else {
                
                VStack {
                    Spacer()
                    Text("Tilt your phone to move your place! \n Press the button to shoot a paper ball!")
                        .bold()
                        .padding(.bottom, 60)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    ButtonOverlay()
                        .padding(.bottom, 20)
                    Image("BlenderSprite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 200)
                        .padding(.bottom, 60)
                }
            }
        }
    }
        
    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: countdownInterval, repeats: true) { timer in
            if countdownStep > 0 {
                countdownStep -= 1
            } else {
                timer.invalidate()
                withAnimation(.easeInOut(duration: 0.5)) {
                    showCountdown = false
                }
            }
        }
    }
    
}

#Preview {
    DogFightiPhoneView()
}
