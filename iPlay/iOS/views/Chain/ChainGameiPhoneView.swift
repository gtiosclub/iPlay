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
    @State private var completionPosition: Int? = nil
    @State private var timer: Timer? = nil
    @State private var timeElapsed: Int = 0
    
    let playerManager = MCPlayerManager.shared!
    let threshold = 3.6
    let wordBank = ["apple", "razor", "desert", "penguin", "moon", "fire", "water", "forest", "robot", "music", "shark", "keyboard", "snow", "book", "train", "dream", "camera", "storm", "clock", "planet"]

    var body: some View {
        VStack(spacing: 20) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(wordChain.indices, id: \.self) { index in
                            Text(wordChain[index])
                                .font(.headline)
                                .id(index)
                            if index != wordChain.count - 1 {
                                Text("→")
                            }
                        }
                        if !gameOver {
                            Text("→ ___")
                        }
                    }
                    .padding()
                }
                .onChange(of: wordChain.count) { _ in
                    withAnimation {
                        proxy.scrollTo(wordChain.count - 1, anchor: .trailing)
                    }
                }
            }
            
            Text("End Word: \(endWord)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if gameOver && isWinner {
                Text("🎉 You Win! 🎉")
                    .font(.title)
                    .foregroundColor(.green)
            } else if gameOver {
                Text("🫵😂 You Lose! ")
                    .font(.title)
                    .foregroundColor(.green)
            }
            
            if showRejectedMessage {
                Text("❌ Word Rejected ❌")
                    .foregroundColor(.red)
                    .transition(.opacity)
            }
            
            if !gameOver {
                TextField("Enter next word", text: $word)
                    .padding()
                    .disableAutocorrection(true)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Button(action: {
                    submitWord()
                }) {
                    Text("Submit")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
        }
        .animation(.easeInOut, value: showRejectedMessage)
        .padding()
        .onChange(of: playerManager.chainCompletionInfo) { newValue in
            if let completion = newValue {
                completionPosition = completion.position
            }
        }
        .onAppear {
            startGame()
            startTimer()
            if let startWord = playerManager.chainStartWord,
               let endWord = playerManager.chainEndWord {
                self.startWord = startWord
                self.endWord = endWord
                self.wordChain = [startWord]
            }
        }
    }
    
    func startGame() {
        showRejectedMessage = false
        gameOver = false
        isWinner = false
        wordChain = []
        chainLinks = []
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            timeElapsed += 1
            if timeElapsed >= 30 {
                gameOver = true
                timer?.invalidate()
            }
        }
    }
    
    func submitWord() {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        word = ""
        
        guard !trimmed.isEmpty else { return }
        
        if checkWordValidity(word: trimmed) {
            wordChain.append(trimmed.capitalized)
            
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
        
        var sum = 0.0
        for i in 0..<vectorA.count {
            sum += pow(vectorA[i] - vectorB[i], 2)
        }
        return sqrt(sum)
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
