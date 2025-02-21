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
    @State private var currentView: ViewState = .preLobby
    
    var body: some View {
        if let mcManager {
            switch mcManager.viewState {
            case .inLobby:
                LobbyView(mcManager: mcManager, username: username)
                
            case .inGame:
                //TODO: Fill in game selection and start of game
                switch mcManager.gameState {
                    case .Infected:
                    Infected(mcManager: mcManager)
                    case .Spectrum:
                        Text("Spectrum")
                }

        
            default:
                Color.blue
            }
        } else {
            switch currentView {
            case .preLobby:
                VStack {
                    Text("iPlay")
                        .font(.title)
                    TextField("Username", text: $username)
                        .padding()
                    Button("Open Lobby") {

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
                        currentView = .inSettings
                    }
                    
                    Button("About") {
                        currentView = .inAbout
                    }
                }
            case .inSettings:
                SettingView()
                
            case .inAbout:
                AboutView()
                
            default:
                Text("uh oh")
                Color.red
            }
            

            
        }
    }
}

#Preview {
    ContentViewMac()
}
