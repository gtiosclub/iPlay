//
//  Chain.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import SwiftUI
import Foundation
import NaturalLanguage

struct Chain: View {
    @Bindable var mcManager: MCHostManager
    @State private var completedPlayers = Set<String>()

    var body: some View {
        VStack(spacing: 20) {
            Text("Word Chains")
                .font(.title)
                .fontWeight(.bold)

            if allPlayersCompleted {
                Text("🎉 All players completed their chains! 🎉")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
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
                                    .foregroundColor(hasCompleted(playerName) ? .green : .primary)
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal)
                            .background(hasCompleted(playerName) ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(hasCompleted(playerName) ? Color.green : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .task {
            checkForCompletedChains()
        }
    }

    var allPlayersCompleted: Bool {
        guard mcManager.gameParticipants.count > 0 else { return false }
        return completedPlayers.count == mcManager.gameParticipants.count
    }

    func formatPlayerChain(_ chain: [ChainLink], playerName: String) -> String {
        let words = chain.map { $0.value }
        let formattedChain = words.joined(separator: " → ")

        if hasCompleted(playerName) {
            return formattedChain + " 🏆"
        } else {
            return formattedChain + " → ___"
        }
    }

    func hasCompleted(_ playerName: String) -> Bool {
        return completedPlayers.contains(playerName)
    }

    func checkForCompletedChains() {
        for (playerName, links) in mcManager.getChainsByPlayer() {
            if let lastWord = links.last?.value,
               lastWord.lowercased() == mcManager.endWord?.lowercased() {
                completedPlayers.insert(playerName)
            }
        }

        if allPlayersCompleted {
            mcManager.allChainPlayersCompleted()
        }
    }
}



//#Preview {
//    Chain(mcManager: MCHostManager(name:))
//}
