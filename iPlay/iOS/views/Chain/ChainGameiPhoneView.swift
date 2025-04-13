//
//  ChainGameiPhoneView.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import Foundation
import SwiftUI
import NaturalLanguage

struct ChainLink: Identifiable, Codable {
    let id = UUID()
    let playerName: String
    let value: String
}

struct ChainiPhoneView: View {
    @State private var word: String = ""
    @State private var wordChain: [String] = []
    @State private var chainLinks: [ChainLink] = []
    @State private var showRejectedMessage: Bool = false
    @State private var gameOver: Bool = false
    @State private var isWinner: Bool = false
    @State private var startWord: String = ""
    @State private var endWord: String = ""
    @State private var guessCounter: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var timer: Timer? = nil
    @FocusState private var fieldIsFocused: Bool
    @State private var completionPosition: Int? = nil

    let playerManager = MCPlayerManager.shared!
    let threshold = 3.6
    let wordBank = ["apple", "razor", "desert", "penguin", "moon", "fire", "water", "forest", "robot", "music", "shark", "keyboard", "snow", "book", "train", "dream", "camera", "storm", "clock", "planet"]

    var body: some View {
        if gameOver {
            if isWinner {
                WinningView(wordChain: wordChain, guessCounter: guessCounter)
            } else {
                LosingView(wordChain: wordChain, currWord: startWord)
            }
        } else {
            ZStack {
                Image("ChainPhoneBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 400, maxHeight: 530)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                Color.blue
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 10) {
                    VStack(spacing: 5) {
                        Text("Target: ")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.trailing, 30)

                        Text(endWord)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 25)

                    Spacer()

                    Image("up-arrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)

                    Spacer()

                    VStack(spacing: 8) {
                        Text(guessCounter == 0 ? "Starting Word: " : "Current Word: ")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(startWord)
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    }

                    VStack {
                        Text("\(guessCounter) guesses")
                            .foregroundColor(.white)
                            .padding(.bottom, 5)

                        if showRejectedMessage {
                            Text("❌ Word Rejected ❌")
                                .foregroundColor(.red)
                                .transition(.opacity)
                                .padding(.bottom, 5)
                        }

                        Text("\(timeRemaining)s")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 40)

                    ZStack(alignment: .trailing) {
                        TextField("Guess a word...", text: $word)
                            .padding()
                            .frame(width: 400, height: 60)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .cornerRadius(10)
                            .autocorrectionDisabled()
                            .focused($fieldIsFocused)
                            .onSubmit { fieldIsFocused = true }
                            .onAppear { fieldIsFocused = true }

                        Button(action: { submitWord() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 241/255, green: 171/255, blue: 134/255))
                                    .frame(width: 40, height: 40)

                                Image("Submit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 15)
                
            }
            .animation(.easeInOut, value: showRejectedMessage)
            .onChange(of: playerManager.chainCompletionInfo) { newValue in
                if let completion = newValue {
                    completionPosition = completion.position
                }
            }
            .onAppear {
                if let start = playerManager.chainStartWord,
                   let end = playerManager.chainEndWord {
                    self.startWord = start.capitalized
                    self.endWord = end.capitalized
                    self.wordChain = [self.startWord]
                    startTimer()
                }
            }
        }
    }

    struct WinningView: View {
        let wordChain: [String]
        let guessCounter: Int

        var body: some View {
            ZStack {
                Image("ChainPhoneBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 400, maxHeight: .infinity)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)

                Color(red: 0.97, green: 0.82, blue: 0.73)
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    Text("Success!")
                        .font(.system(size: 38, weight: .bold))
                        .padding(.top, 40)

                    Text("You completed the chain in \(guessCounter) steps!")
                        .font(.system(size: 18, weight: .medium))

                    Text("Check the big screen to view the leaderboard and scores!")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 20)

                    Text("Your Chain:")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        ForEach(0..<wordChain.count, id: \.self) { index in
                            Text(wordChain[index])
                                .font(.system(size: 20))
                        }
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
        }
    }

    struct LosingView: View {
        let wordChain: [String]
        let currWord: String

        var body: some View {
            ZStack {
                Image("ChainPhoneBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 400, maxHeight: .infinity)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)

                Color(.red)
                    .opacity(0.6)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    Text("Time's up!")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    Text("Your last word was \"" + currWord + "\"")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)

                    Text("Check the big screen to view the leaderboard and scores!")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 20)

                    Text("Your Chain:")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)

                    VStack(spacing: 12) {
                        ForEach(0..<wordChain.count, id: \.self) { index in
                            Text(wordChain[index])
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()
                }
                .padding(.top, 20)
            }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                gameOver = true
            }
        }
    }

    func submitWord() {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        word = ""
        
        guard !trimmed.isEmpty else { return }
        
        guessCounter += 1
        
        if checkWordValidity(word: trimmed) {
            wordChain.append(trimmed.capitalized)
            startWord = trimmed.capitalized
            
            let newLink = ChainLink(playerName: playerManager.currentPlayer.id.displayName, value: trimmed.capitalized)
            chainLinks.append(newLink)
            playerManager.submitChainLinks(chainLinks)

            let chainString = wordChain.joined(separator: " → ")
            print("Current chain: \(chainString)")

            if trimmed.lowercased() == endWord.lowercased() {
                gameOver = true
                isWinner = true
            }
        } else {
            showRejected()
        }
    }

    func checkWordValidity(word: String) -> Bool {
        guard let lastWord = wordChain.last else { return false }
        let similarityScore = computeSimilarity(word_1: lastWord.lowercased(), word_2: word.lowercased())
        return similarityScore < threshold
    }

    func computeSimilarity(word_1: String, word_2: String) -> Double {
        guard let embedding = NLEmbedding.wordEmbedding(for: .english),
              let vectorA = embedding.vector(for: word_1),
              let vectorB = embedding.vector(for: word_2) else {
            return 10.0
        }
        
        return sqrt(zip(vectorA, vectorB).map { pow($0 - $1, 2) }.reduce(0, +))
    }

    func showRejected() {
        withAnimation {
            showRejectedMessage = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showRejectedMessage = false
            }
        }
    }
}


//#Preview {
//    ChainiPhoneView()
//}
