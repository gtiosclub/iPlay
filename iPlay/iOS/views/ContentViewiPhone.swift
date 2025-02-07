//
//  ContentViewiPhone.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import SwiftUI
import MultipeerConnectivity

struct ContentViewiPhone: View {
    @State private var username = ""
    @State private var mcManager: MCPlayerManager?
    var body: some View {
        if let mcManager {
            switch mcManager.viewState {
            case .preLobby:
                VStack {
                    Text("Looking for lobbies...")
                    List {
                        ForEach(Array(mcManager.openLobbies)) { lobby in
                            Section {
                                HStack {
                                    Text("\(lobby.id.displayName)'s Lobby")
                                    Button("Join") {
                                        if let session = mcManager.session {
                                            mcManager.browser.invitePeer(lobby.id, to: session, withContext: nil, timeout: 50)
                                            print("Invited")
                                        } else {
                                            print("No session")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .inLobby:
                Text("Welcome to the lobby")
                
            case .inGame:
                //TODO: Add views for in Game
                InGameViewiPhone()
            }
        } else {
            VStack {
                TextField("Username", text: $username)
                Button("Look For Lobbies") {
                    MCPlayerManager.createSharedInstance(name: username)
                    mcManager = MCPlayerManager.shared
                    if let mcManager {
                        mcManager.viewState = .preLobby
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
    ContentViewiPhone()
}
