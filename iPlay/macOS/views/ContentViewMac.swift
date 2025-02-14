//
//  ContentViewMac.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import SwiftUI

struct ContentViewMac: View {
    @State private var username = ""
    @State private var mcManager: MCHostManager?
    var body: some View {
        if let mcManager {
            switch mcManager.viewState {
            case .inLobby:
                LobbyView(mcManager: mcManager, username: username)
                
            case .inGame:
                //TODO: Fill in game selection and start of game
                switch mcManager.gameState {
                    case .Infected:
                        Infected()
                    case .Spectrum:
                        Text("Spectrum")
                }
                
            case .inSettings:
                Text("Settings coming soon")
                Color.black
                
            case .inAbout:
                Text("About coming soon")
                Color.black
        
            default:
                Color.blue
            }
        } else {
            VStack {
                Text("iPlay")
                    .font(.title)
                TextField("Username", text: $username)
                
                Button("Start Lobby") {
                    MCHostManager.createSharedInstance(name: username)
                    mcManager = MCHostManager.shared
                    if let mcManager {
                        mcManager.viewState = .inLobby
                        mcManager.gameState = .Infected
                        mcManager.start()
                    } else {
                        print("MC Manager not initialized")
                    }
                }
                
                Button("Settings") {
                    if let mcManager {
                        mcManager.viewState = .inSettings
                        mcManager.start()
                    } else {
                        print("MC Manager not initialized")
                    }
                }
                
                Button("About") {
                    if let mcManager {
                        mcManager.viewState = .inAbout
                        mcManager.start()
                    } else {
                        print("MC Manager not initialized")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentViewMac()
}
