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
                mcManager.viewState = .inGame
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    LobbyView(mcManager: MCHostManager(name: "HostName"), username: "NoName")
}
