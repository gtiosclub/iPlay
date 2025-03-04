//
//  ContentViewiPhone.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

#if os(iOS)

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
//                InfectedInGameViewiPhone()
                Button("Send String") {
                    mcManager.sendHint("Hello")
                }
                
            case .inGame:
                //TODO: Add views for in Game
                switch mcManager.gameState {
                    case .Infected:
                    InfectedInGameViewiPhone()
                    case .Spectrum:
                    switch mcManager.spectrumPhoneState {
                    case .instructions:
                        Color.black
                    case .youGivingPrompt:
                        YouAreGivingTheHintView(prompt: mcManager.spectrumPrompt!, playerManager: $mcManager)
                    case .waitingForPrompter:
                        YouAreGuessingStartView()
                    case .waitForGuessers:
                        if let prompt = mcManager.spectrumPrompt, prompt.isHinter {
                            HintSubmittedView()
                        } else {
                            GuessSubmittedView()
                        }
                    case .youAreGuessing:
                        YouAreGuessingView(hint: mcManager.spectrumHint!, prompt: mcManager.spectrumPrompt!.prompt, playerManager: $mcManager)
                    case .revealingGuesses:
                        RevealingGuessesView()
                    case .pointsAwarded:
                        Color.black
                    }
                }
            }
        } else {
            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    #endif
                    /*
                     This is needed since we are using a multiplatform app
                     so we need to check if os is iOS for disabling contextual
                     autocapitalization and autocorrect modifiers (QOL)
                    */
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

#endif
