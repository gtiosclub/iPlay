//
//  Chain.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import SwiftUI

struct Chain: View {
    @Bindable var mcManager: MCHostManager
    @State private var timeRemaining = 60
    @State private var timer: Timer?

    var body: some View {
        ZStack{
            Image("ChainBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            VStack(spacing: 16) {
                HStack(alignment: .center, spacing: 10) {
                    if let start = mcManager.chainStartWord, let end = mcManager.chainEndWord {
                        Text(start)
                            .font(.title)
                            .bold()
                        ZStack(alignment: .trailing) {
                            Rectangle()
                                .frame(width: 500, height: 4)
                                .foregroundColor(.black)
                            Triangle()
                                .fill(Color.black)
                                .frame(width: 14, height: 14)
                                .rotationEffect(.degrees(90))
                                .offset(x: 6)
                        }
                        Text(end)
                            .font(.title)
                            .bold()
                    } else {
                        Text("Waiting for words...")
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(mcManager.chainPlayers, id: \.id) { player in
                            let chain = player.chain
                            let isDone = mcManager.completedChainPlayers.contains(player.id)
                            let position = mcManager.completedChainPlayers.firstIndex(of: player.id).map { $0 + 1 }
                            
                            HStack(spacing: 12) {
                                ChainLinkView(count: chain.count, isCompleted: isDone)
                                
                                Text(player.name)
                                    .font(.system(size: 18, weight: .semibold))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 8)
                                    .foregroundColor(.white)
                                    .background(Color.black)
                                    .clipShape(Capsule())
                                
                                if let pos = position {
                                    Text("\(ordinal(pos))")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    //                                    .font(.caption)
                                    //                                    .foregroundColor(.blue)
                                    //                                    .padding(.leading, 4)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                
                Spacer()
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 18)
                            .foregroundColor(Color.gray.opacity(0.3))
                        Capsule()
                            .frame(width: CGFloat(timeRemaining) / 60 * (geo.size.width - 32), height: 18)
                            .foregroundColor(timeRemaining <= 10 ? .red : .blue)
                            .animation(.easeInOut, value: timeRemaining)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .frame(height: 30)
                }
            }
            .padding(.top)
            .onAppear {
                mcManager.generateChainWords()
                startTimer()
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            if timeRemaining <= 0 || mcManager.completedChainPlayers.count == mcManager.gameParticipants.count {
                endGame()
            }
        }
    }

    func endGame() {
        timer?.invalidate()
        timer = nil
        mcManager.applyChainPointsToGameParticipants()
        mcManager.viewState = .scoreboard
        print("Chain game ended.")
    }

    func ordinal(_ number: Int) -> String {
        let suffix: String
        switch number {
        case 1: suffix = "st"
        case 2: suffix = "nd"
        case 3: suffix = "rd"
        default: suffix = "th"
        }
        return "\(number)\(suffix)"
    }
}

struct ChainLinkView: View {
    let count: Int
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: -8) {
            ForEach(0..<count, id: \.self) { index in
                if index % 2 == 0 {
                    Capsule()
                        .frame(width: 75, height: 15)
                        .foregroundColor(isCompleted ? .green : .black)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isCompleted ? Color.green : Color.black, lineWidth: 5)
                        .frame(width: 75, height: 30)
                }
            }
        }
    }
}

//#Preview {
//    VStack(spacing: 20) {
//        ChainLinkView(count: 5, isCompleted: false)
//        ChainLinkView(count: 6, isCompleted: true)
//    }
//    .padding()
//}



//#Preview {
//    Chain(mcManager:MCHostManager.shared!)
//}
