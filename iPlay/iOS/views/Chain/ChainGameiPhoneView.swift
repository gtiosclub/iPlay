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
    @State private var startWord: String = ""
    @State private var endWord: String = ""
    
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

            if gameOver {
                Text("🎉 You Win! 🎉")
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
        .onAppear {
            let (start, end) = pickStartAndEndWords()
            startWord = start.capitalized
            endWord = end.capitalized
            wordChain = [startWord]
        }
    }
    
    func submitWord() {
        let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        word = ""
        
        guard !trimmed.isEmpty else { return }
        
        if checkWordValidity(word: trimmed) {
            wordChain.append(trimmed.capitalized)
            
            // Create a new ChainLink and add it to the array
            let newLink = ChainLink(playerName: playerManager.currentPlayer.id.displayName, value: trimmed.capitalized)
            chainLinks.append(newLink)
            
            // Send the updated chain to the host
            playerManager.submitChainLinks(chainLinks)
            
            // Print the chain locally
            let chainString = wordChain.joined(separator: " → ")
            print("Current chain: \(chainString)")

            if trimmed.lowercased() == endWord.lowercased() {
                gameOver = true
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
    
    func pickStartAndEndWords() -> (String, String) {
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
            let start = "Apple"
            self.chainLinks = [ChainLink(playerName: playerManager.currentPlayer.id.displayName, value: start)]
            return (start, "Razor")
        }

        for _ in 0..<100 {
            let start = wordBank.randomElement()!
            self.chainLinks = [ChainLink(playerName: playerManager.currentPlayer.id.displayName, value: start.capitalized)]
            let end = wordBank.randomElement()!
            if start == end { continue }

            if let vec1 = embedding.vector(for: start),
               let vec2 = embedding.vector(for: end) {
                let distance = zip(vec1, vec2).map { pow($0 - $1, 2) }.reduce(0, +).squareRoot()
                if distance > 1.5 && distance < 4.0 {
                    return (start, end)
                }
            }
        }
        return ("Apple", "Razor")
    }
}

//#Preview {
//    ChainiPhoneView()
//}
