//
//  LobbyView.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/7/25.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var mcManager: MCHostManager
    var username: String
    
    var body: some View {
        VStack {
            Text("\(username)'s Lobby")
            List {
                ForEach(Array(mcManager.gameParticipants)) { player in
                    Section {
                        Text(player.id.displayName)
                    }
                }
            }

            Text("Select Game:")
            Button("Infected") {
                mcManager.gameState = .Infected
            }
            Button("Spectrum") {
                mcManager.gameState = .Spectrum
            }
            
            Button("Start Game: \(mcManager.gameState)") {
                if mcManager.gameState == .Infected {
                    createInfectedPlayers()
                }
                mcManager.viewState = .inGame
                mcManager.sendGameState(mcManager.gameState)
            }
            .padding(.vertical, 40)
        }
    }
    func createInfectedPlayers() {
        for player in mcManager.gameParticipants {
            mcManager.infectedPlayers.append(InfectedPlayer(id: player.id, name: player.id.displayName, isInfected: false))
        }
        let randomIndex = Int.random(in: 0..<mcManager.infectedPlayers.count)
        mcManager.infectedPlayers[randomIndex].isInfected = true
        
    }
}

#Preview {
    LobbyView(mcManager: MCHostManager(name: "HostName"), username: "NoName")
}
