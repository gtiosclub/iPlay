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
    @State private var guessCounter: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var timer: Timer? = nil
    @FocusState private var fieldIsFocused: Bool
    @State private var navigateToWin = false
    @State private var navigateToLose = false
    
    let playerManager = MCPlayerManager.shared!
    let threshold = 3.6
    let wordBank = ["apple", "razor", "desert", "penguin", "moon", "fire", "water", "forest", "robot", "music", "shark", "keyboard", "snow", "book", "train", "dream", "camera", "storm", "clock", "planet"]
    
    
    var body: some View {
        if (gameOver) {
            if (startWord == endWord) {
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
                    
                // Blue overlay with opacity
                Color.blue
                    .opacity(0.6) // Adjust opacity value as needed
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
                    
                    VStack(spacing: 8) {
                        Image("up-arrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        if (guessCounter == 0) {
                            Text("Starting Word: ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.trailing, 9)
                        } else {
                            Text("Current Word: ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.trailing, 9)
                        }
                        
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
                    }
                    .padding(.horizontal, 40)
                    
                    ZStack(alignment: .trailing) {
                        TextField("Guess a word...", text: $word)
                            .padding()
                            .frame(width: 400 , height: 60)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .accentColor(.white) // Makes the caret white
                            .cornerRadius(10)
                            .autocorrectionDisabled()
                            .onSubmit {
                                fieldIsFocused = true
                            }
                            .focused($fieldIsFocused)
                            .onAppear {
                                fieldIsFocused = true
                            }
                        
                        Button(action: { submitWord() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 241/255, green: 171/255, blue: 134/255))
                                    .frame(width: 40, height: 40) // Customize size here

                                Image("Submit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // Adjust based on your icon size
                            }
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.top, 15)
                .padding()
            }
            .animation(.easeInOut, value: showRejectedMessage)
                .onAppear {
                    let (start, end) = pickStartAndEndWords()
                    startWord = start.capitalized
                    endWord = end.capitalized
                    wordChain = [startWord]
                    startTimer()
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
                
                // Peach background color
                Color(red: 0.97, green: 0.82, blue: 0.73)
                    .opacity(0.6) // Adjust opacity value as needed
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
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Text("Your Chain:")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 12) {
                        // Using a loop to display all words in the chain
                        ForEach(0..<wordChain.count) { index in
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
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Text("Your Chain:")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 12) {
                        // Using a loop to display all words in the chain
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
    
    // Timer on the Phone Side
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
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
            startWord = wordChain[wordChain.count - 1]
            
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
