//
//  EmojiMatchGameView.swift
//  iplaytest
//
//  Created by Alexandria Ober on 3/25/25.
//
import SwiftUI

enum EmojiTypes: String, CaseIterable, Codable {
    case happy = "EmojiMatch-HappyEmoji"
    case neutral = "EmojiMatch-NeutralEmoji"
    case suprised = "EmojiMatch-SuprisedEmoji"
    case fear = "EmojiMatch-FearEmoji"
    case angry = "EmojiMatch-AngryEmoji"
    case sad = "EmojiMatch-SadEmoji"
}

enum EmojiMatchMacState {
    case inGame, leaderboard
}

#if os(macOS)

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct EmojiMatchGameView: View {
    @ObservedObject var mcManager: MCHostManager
    
    @State private var countdown = 3
    @State private var gameCounter = 0
    let gameCountTo = 30
    
    @State var votingTimer = 20
    @State var gameState: EmojiMatchMacState = .inGame {
        didSet {
            if gameState == .inGame {
                countdown = 3
                gameCounter = 0
                
                votingTimer = 20
            }
        }
    }

    var body: some View {
        if gameState == .inGame {
            ZStack {
                Image("EmojiMatchBackground")
                    .resizable()
                    .scaledToFill()
                
                VStack {
                    Spacer()
                    Spacer()
                    
                    if countdown > 0 {
                        Text("Get ready to match the emoji in...")
                            .font(.system(size: 30, weight: .medium, design: .monospaced))
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
                                    if gameCounter == gameCountTo {
                                        mcManager.sendEmojiMatchState(state: .voting)
                                    }
                                }
                            }
                    } else {
                        HStack {
                            Spacer()
                            Text("Time To Vote!")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                        Text(String(votingTimer))
                            .font(.system(size: 35))
                            .foregroundStyle(.black)
                            .onReceive(timer) { _ in
                                votingTimer -= 1
                                if votingTimer == 0 {
                                    mcManager.calculateAIVote()
                                    gameState = .leaderboard
                                }
                            }
                        
                        HStack {
                            ForEach(Array(mcManager.gameParticipants), id: \.id) { player in
                                VStack {
                                    if let playerImage = mcManager.emojiMatchImages[player.id] {
                                        ZStack {
                                            Image(nsImage: playerImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150)
                                                .clipShape(Circle())
                                            
                                            Image("circleHolePaper")
                                                .resizable()
                                                .scaledToFit()
                                                .scaleEffect(1.6)
                                                .offset(y: 1)
                                                .frame(width: 150, height: 150)
                                                .clipShape(Circle())
                                        }
                                        .frame(width: 150, height: 150)
                                    }
                                    
                                    Image(player.avatar)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                }
                            }
                        }
                        

                    }
                    
                    Spacer()
                    Image(MCHostManager.shared!.emojiMatchEmoji.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130)
                    Spacer()
                    Spacer()
                }
            }
            .onChange(of: gameState) { oldValue, newValue in
                if newValue == .inGame {
                    countdown = 3
                    gameCounter = 0
                    
                    votingTimer = 20
                }
            }
        } else {
            GeometryReader { context in
                ZStack {
                    Image(.emojiMatchBackground)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    VStack {
                        ForEach(Array(MCHostManager.shared!.gameParticipants), id: \.id) { player in
                            HStack {
                                Spacer()
                                
                                Image(player.avatar)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                
                                ZStack {
                                    if let image = MCHostManager.shared!.emojiMatchImages[player.id] {
                                        ZStack {
                                            Image(nsImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150)
                                                .clipShape(Circle())
                                            
                                            Image("circleHolePaper")
                                                .resizable()
                                                .scaledToFit()
                                                .scaleEffect(1.6)
                                                .offset(y: 1)
                                                .frame(width: 150, height: 150)
                                                .clipShape(Circle())
                                        }
                                        .frame(width: 150, height: 150)
                                    }
                                }
                                
                                Text("\(MCHostManager.shared!.emojiMatchVotes[player.id, default: 0]) votes")
                                    .foregroundStyle(.black)
                                
                                if let aiGuess = MCHostManager.shared!.emojiMatchAIVote, aiGuess == player.id {
                                    Text("EmojiAI Voted for You!")
                                        .foregroundStyle(.black)
                                }

                                Spacer()
                                Spacer()
                            }
                        }
                    }
                    
                    HStack {
                        VStack {
                            Button {
                                MCHostManager.shared!.viewState = .inLobby
                                MCHostManager.shared!.emojiMatchImages = [:]
                                MCHostManager.shared!.emojiMatchScores = [:]
                                MCHostManager.shared!.emojiMatchScores = [:]
                                MCHostManager.shared!.emojiMatchEmoji = .happy
                                MCHostManager.shared!.emojiMatchAIVote = .none
                            } label: {
                                Image(systemName: "x.circle")
                                    .foregroundStyle(.black)
                                    .imageScale(.large)
                            }
                
                            Spacer()
                            
                            Button {
                                MCHostManager.shared!.emojiMatchImages = [:]
                                MCHostManager.shared!.emojiMatchScores = [:]
                                MCHostManager.shared!.emojiMatchScores = [:]
                                MCHostManager.shared!.emojiMatchEmoji = .happy
                                MCHostManager.shared!.emojiMatchAIVote = .none
                                MCHostManager.shared!.sendEmojiMatchState(state: .start)
                                countdown = 3
                                gameCounter = 0
                                votingTimer = 20
                                gameState = .inGame
                                
                            } label: {
                                Text("Play Again?")
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }

    func startCountdown() {
        mcManager.pickOutEmoji()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                mcManager.sendEmojiMatchEmoji()
                mcManager.sendEmojiMatchState(state: .takingPicture)
                mcManager.sendOutEmojiMatchPlayers()
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
                Image(MCHostManager.shared!.emojiMatchEmoji.rawValue)
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

#endif
