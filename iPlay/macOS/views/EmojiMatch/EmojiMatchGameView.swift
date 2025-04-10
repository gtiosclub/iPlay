//
//  EmojiMatchGameView.swift
//  iplaytest
//
//  Created by Alexandria Ober on 3/25/25.
//
import SwiftUI

enum EmojiTypes: String, CaseIterable {
    case happy = "EmojiMatch-HappyEmoji"
    case neutral = "EmojiMatch-NeutralEmoji"
    case suprised = "EmojiMatch-SuprisedEmoji"
}

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct EmojiMatchGameView: View {
    @ObservedObject var mcManager: MCHostManager
    
    @State private var countdown = 3
    @State private var gameCounter = 0
    let gameCountTo = 30

    var body: some View {
        ZStack {
            Image("EmojiMatchBackground")
                .resizable()
                .scaledToFill()

            VStack {
                Spacer()
                Spacer()
                
                if countdown > 0 {
                    Text("Get ready to match the emoji in...")
                        .font(.custom("SFMono-Medium", size: 20))
                        .padding(.bottom, 10)
                    Text("\(countdown)")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black)
                        .onAppear {
                            startCountdown()
                        }
                } else if gameCounter < gameCountTo {
                    CountdownView(counter: gameCounter, countTo: gameCountTo)
                        .frame(width: 250, height: 250)
                        .onReceive(timer) { _ in
                            if gameCounter < gameCountTo {
                                gameCounter += 1
                            }
                        }
                } else {
                    Text("Time's up!")
                        .font(.system(size: 50, weight: .semibold))
                        .padding(.top, 40)
                    Text("The winner is...")
                        .font(.custom("SFMono-Medium", size: 20))
                        .foregroundColor(.black)
                }
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }

    func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
struct Clock: View {
    var counter: Int
    var countTo: Int

    var body: some View {
        Text(counterToMinutes())
            .font(.system(size: 25, weight: .semibold, design: .default))
    }

    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = currentTime / 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}

struct ProgressTrack: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 150, height: 150)
            .overlay(
                Circle().stroke(Color.black.opacity(0.2), lineWidth: 5)
            )
            
    }
}

struct ProgressBar: View {
    var counter: Int
    var countTo: Int

    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: 150, height: 150)
            .overlay(
                Circle()
                    .trim(from: 0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .foregroundColor(completed() ? .green : .orange)
                    .animation(.easeInOut(duration: 0.2), value: progress())
            )
    }

    func completed() -> Bool {
        return progress() == 1
    }

    func progress() -> CGFloat {
        return CGFloat(counter) / CGFloat(countTo)
    }
}

struct CountdownView: View {
    var counter: Int
    var countTo: Int
    
    var body: some View {
        VStack() {
            ZStack {
                ProgressTrack()
                ProgressBar(counter: counter, countTo: countTo)
                Image(EmojiTypes.allCases.randomElement()!.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                
            }
            Clock(counter: counter, countTo: countTo)
        }
    }
}

#Preview {
    EmojiMatchGameView(mcManager: .init(name: "Preview"))
}

