//
//  Chain.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import SwiftUI

struct Chain: View {
    @Bindable var mcManager: MCHostManager
    @State private var completedPlayers = [String]() // Preserves order
    @State private var timeRemaining = 10
    @State private var gameEnded = false
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 20) {
            Text("Word Chains")
                .font(.title)
                .fontWeight(.bold)

            Text("Time Remaining: \(timeRemaining) sec")
                .font(.subheadline)
                .foregroundColor(timeRemaining <= 10 ? .red : .secondary)

            if gameEnded {
                Text("⏱️ Game Over!")
                    .font(.headline)
                    .foregroundColor(.red)
            } else if mcManager.gameParticipants.count > 0 &&
                        completedPlayers.count == mcManager.gameParticipants.count {
                Text("🎉 All players completed their chains! 🎉")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 15) {
                    ForEach(Array(mcManager.getChainsByPlayer().keys), id: \.self) { playerName in
                        if let playerChain = mcManager.getChainsByPlayer()[playerName] {
                            VStack(alignment: .leading) {
                                Text(playerName)
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                Text(formatPlayerChain(playerChain, playerName: playerName))
                                    .font(.subheadline)
                                    .padding(.leading, 10)
                                    .foregroundColor(isCompleted(playerName) ? .green : .primary)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                            .background(isCompleted(playerName) ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isCompleted(playerName) ? Color.green : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            mcManager.generateChainWords()
            startTimer()
        }
        .onChange(of: mcManager.getChainsByPlayer()) { _ in
            checkForCompletedChains()
        }
    }

    func isCompleted(_ playerName: String) -> Bool {
        completedPlayers.contains(playerName)
    }

    func checkForCompletedChains() {
        guard !gameEnded else { return }

        for (playerName, chain) in mcManager.getChainsByPlayer() {
            if !completedPlayers.contains(playerName),
               let last = chain.last,
               last.lowercased() == mcManager.endWord?.lowercased() {
                completedPlayers.append(playerName)
                awardPoints(to: playerName)
            }
        }

        if mcManager.gameParticipants.count > 0 &&
            completedPlayers.count == mcManager.gameParticipants.count {
            endGame()
        }
    }

    func awardPoints(to playerName: String) {
        // Points: 50 for 1st, 40 for 2nd, ...
        let index = completedPlayers.count - 1
        let points = max(50 - index * 10, 10)

        if let idx = mcManager.chainPlayers.firstIndex(where: { $0.name == playerName }) {
            mcManager.chainPlayers[idx].points += points
            print("\(playerName) awarded \(points) points!")
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            timeRemaining -= 1
            if timeRemaining <= 0 {
                endGame()
            }
        }
    }

    func endGame() {
        timer?.invalidate()
        timer = nil
        gameEnded = true
        mcManager.applyChainPointsToGameParticipants()
        mcManager.viewState = .scoreboard
        print("Chain game ended.")
    }
    
    func getPositionText(playerName: String) -> String {
        guard let index = mcManager.completedChainPlayers.firstIndex(where: { $0.displayName == playerName }) else {
            return ""
        }
        
        let position = index + 1
        let suffix: String
        switch position {
        case 1: suffix = "st"
        case 2: suffix = "nd"
        case 3: suffix = "rd"
        default: suffix = "th"
        }
        
        return " (Finished \(position)\(suffix))"
    }
    
    func formatPlayerChain(_ chain: [String], playerName: String) -> String {
        let formatted = chain.joined(separator: " → ")
        if isCompleted(playerName) {
            return formatted + " 🏆" + getPositionText(playerName: playerName)
        } else {
            return formatted
        }
    }

}




//#Preview {
//    Chain(mcManager: MCHostManager(name:))
//}
