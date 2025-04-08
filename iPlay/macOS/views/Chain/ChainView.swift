//
//  ChainView.swift
//  iPlay
//
//  Created by Jason Nair on 4/8/25.
//

import SwiftUI
import Foundation
import SpriteKit
import NaturalLanguage

struct ChainView: View {
    @ObservedObject var mcManager: MCHostManager
    @State private var gameTimer: Timer?
    @State private var timeRemaining: Int = 120 // 2 minutes
    @State private var startWord: String = "penguin"
    @State private var endWord: String = "desert"
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.98, green: 0.95, blue: 0.92)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Start and End Words
                HStack(spacing: 15) {
                    Text(startWord.capitalized)
                        .font(.system(size: 30, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24))
                    
                    Text(endWord.capitalized)
                        .font(.system(size: 30, weight: .bold))
                }
                .padding(.top, 30)
                
                // Player Chains
                ScrollView {
                    VStack(spacing: 18) {
                        ForEach(Array(mcManager.chainLinks.reduce(into: [String: [ChainLink]]()) { result, link in
                            result[link.playerName, default: []].append(link)
                        }.sorted { $0.key < $1.key }), id: \.key) { playerName, links in
                            PlayerChainView(
                                playerName: playerName,
                                links: links,
                                hasLead: isClosestToEndWord(playerName: playerName),
                                endWord: endWord
                            )
                        }
                    }
                    .padding()
                }
                
                // Timer at bottom
                HStack {
                    Spacer()
                    ZStack {
                        Capsule()
                            .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                            .frame(width: 400, height: 40)
                        
                        Text("\(timeRemaining) seconds remain")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            setupGame()
            startTimer()
        }
        .onDisappear {
            gameTimer?.invalidate()
        }
    }
    
    func setupGame() {
        // Reset and initialize game state
        mcManager.chainLinks = []
        timeRemaining = 120
        
        // Randomly select two words from the word bank that have enough semantic distance
        pickStartAndEndWords()
        
        // Start the timer on the host side
        mcManager.startChainTimer()
    }
    
    func startTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame()
            }
        }
    }
    
    func endGame() {
        gameTimer?.invalidate()
        mcManager.viewState = .scoreboard
        // Award points to players
        awardPoints()
    }
    
    func awardPoints() {
        // Award points based on proximity to the end word and number of valid words
        var updatedPlayers = mcManager.gameParticipants
        
        // Group links by player
        let playerLinks = mcManager.chainLinks.reduce(into: [String: [ChainLink]]()) { result, link in
            result[link.playerName, default: []].append(link)
        }
        
        for (playerName, links) in playerLinks {
            if let player = mcManager.gameParticipants.first(where: { $0.id.displayName == playerName }) {
                var updatedPlayer = player
                
                // Base points for participation
                let basePoints = 5
                
                // Points for each valid word in chain
                let wordPoints = links.count * 2
                
                // Bonus points for getting closest to end word
                let bonusPoints = isClosestToEndWord(playerName: playerName) ? 10 : 0
                
                // Update player's score
                updatedPlayer.points += (basePoints + wordPoints + bonusPoints)
                
                updatedPlayers.remove(player)
                updatedPlayers.insert(updatedPlayer)
            }
        }
        
        mcManager.gameParticipants = updatedPlayers
    }
    
    func isClosestToEndWord(playerName: String) -> Bool {
        // Group links by player
        let playerLinks = mcManager.chainLinks.reduce(into: [String: [ChainLink]]()) { result, link in
            result[link.playerName, default: []].append(link)
        }
        
        var closestDistance = Double.infinity
        var closestPlayer = ""
        
        for (name, links) in playerLinks {
            if let lastWord = links.last?.value {
                let distance = computeSimilarity(word_1: lastWord, word_2: endWord)
                if distance < closestDistance {
                    closestDistance = distance
                    closestPlayer = name
                }
            }
        }
        
        return playerName == closestPlayer
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
    
    func pickStartAndEndWords() {
        let wordBank = ["apple", "razor", "desert", "penguin", "moon", "fire", "water", "forest", "robot",
                      "music", "shark", "keyboard", "snow", "book", "train", "dream", "camera", "storm", "clock", "planet"]
        
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
            startWord = "penguin"
            endWord = "desert"
            return
        }

        for _ in 0..<100 {
            let start = wordBank.randomElement()!
            let end = wordBank.randomElement()!
            if start == end { continue }

            if let vec1 = embedding.vector(for: start),
               let vec2 = embedding.vector(for: end) {
                let distance = zip(vec1, vec2).map { pow($0 - $1, 2) }.reduce(0, +).squareRoot()
                if distance > 1.5 && distance < 4.0 {
                    startWord = start
                    endWord = end
                    return
                }
            }
        }
        
        // Fallback to default words
        startWord = "penguin"
        endWord = "desert"
    }
}

struct PlayerChainView: View {
    let playerName: String
    let links: [ChainLink]
    let hasLead: Bool
    let endWord: String
    
    var body: some View {
        HStack {
            // Player avatar/indicator
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                )
                .overlay(
                    ZStack {
                        if hasLead {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.yellow)
                                .offset(y: -25)
                        }
                    }
                )
            
            // Player name
            Text(playerName)
                .font(.system(size: 20, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(hasLead ? Color(red: 0.95, green: 0.7, blue: 0.5) : Color(red: 0.2, green: 0.2, blue: 0.2))
                )
                .foregroundColor(hasLead ? .black : .white)
            
            // Chain links
            ChainLinksView(links: links)
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

struct ChainLinksView: View {
    let links: [ChainLink]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<links.count, id: \.self) { index in
                HStack(spacing: 0) {
                    // Chain link image
                    Image(systemName: "link")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    if index < links.count - 1 {
                        // Connecting line
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 5, height: 2)
                    }
                }
            }
        }
    }
}

#Preview {
    ChainView(mcManager: MCHostManager(name: "PreviewHost"))
}
