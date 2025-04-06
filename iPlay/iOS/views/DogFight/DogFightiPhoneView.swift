//
//  DogFightiPhoneView.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/25/25.
//
#if os(iOS)
import SwiftUI

struct DogFightiPhoneView: View {
    @State private var countdownStep = 3
    @State private var showCountdown = true
    @State private var wasHit = false
    @State private var tookDamage = false
    @StateObject private var motionRecorder = MotionRecorder()
    

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
                        motionRecorder.startFetchingMotionData()
                        startSendingAngle()
                    }
            } else {
                
                VStack {
//                    Spacer()
                    Text("Tilt your phone to move your place! \n Press the button to shoot a paper ball!")
                        .bold()
                        .padding(.bottom, 60)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                    ButtonOverlay(onPress: {
                        loseLife()
                    })
                        .padding(.bottom, 20)
                    Image("BlenderSprite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 200)
//                        .padding(.bottom, 60)
                    Text(String(format: "Tilt: %.2f", motionRecorder.tilt))
                        .foregroundColor(.white)
                }
            }
            
            if tookDamage {
                Color.red
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .transition(.opacity)
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
    
    func startSendingAngle() {
        let sendAngleTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {_ in
            let angle = max(-Double.pi / 2, min(Double.pi / 2, motionRecorder.tilt))
            MCPlayerManager.shared?.sendAngle(angle: angle)
        }
        RunLoop.current.add(sendAngleTimer, forMode: .default)
    }
    
    func loseLife() {
        withAnimation(.easeIn(duration: 0.1)) {
            tookDamage = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 1.0)) {
                tookDamage = false
            }
        }
    }
    
}

#Preview {
    DogFightiPhoneView()
}
#endif
