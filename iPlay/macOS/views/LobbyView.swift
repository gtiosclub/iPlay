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
            
            Button("Dog Fight") {
                mcManager.gameState = .DogFight
            }
            
            Button("Emoji Match") {
                mcManager.gameState = .EmojiMatch
            }
            
            Button("Chain") {
                mcManager.gameState = .Chain
            }
            
            Button("Start Game: \(mcManager.gameState)") {
                    if mcManager.gameState == .Infected {
                        createInfectedPlayers()
                    }
                    mcManager.viewState = .inGame
                    if mcManager.gameState == .Spectrum {
                        print("Sending out spectrum data")
                        mcManager.sendOutInitialSpectrumData()
                    }
                    mcManager.sendGameState()
            }
            .padding(.vertical, 40)
            .disabled(mcManager.gameParticipants.count < 1)
        }
    }
    func createInfectedPlayers() {
        mcManager.infectedPlayers.removeAll()
        for player in mcManager.gameParticipants {
            mcManager.infectedPlayers.append(InfectedPlayer(id: player.id, name: player.id.displayName, isInfected: false))
        }
        let randomIndex = Int.random(in: 0..<mcManager.infectedPlayers.count)
        mcManager.infectedPlayers[randomIndex].isInfected = true
        for player in mcManager.infectedPlayers {
            let infectedState = MCInfectedState(infected: player.isInfected, playerID: player.id.displayName)
            mcManager.sendInfectedState(infectedState)
        }
        
        
    }
}

#Preview {
    LobbyView(mcManager: MCHostManager(name: "HostName"), username: "NoName")
}
