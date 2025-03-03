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
    @State private var isNavigating = false
    var body: some View {
        NavigationStack{
            if let mcManager {
                switch mcManager.viewState {
                case .preLobby:
                    VStack {
                        Text("Looking for lobbies...")
                            .padding(.top, 25)
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
                    .background(.white)
                case .inLobby:
                    //                InfectedInGameViewiPhone()
                    Button("Send String") {
                        mcManager.sendPrompt("Hello")
                    }
                    
                case .inGame:
                    //TODO: Add views for in Game
                    switch mcManager.gameState {
                    case .Infected:
                        InfectedInGameViewiPhone()
                    case .Spectrum:
                        Text("Spectrum")
                    }
                }
            } else {
                
                VStack(spacing:20) {
                    VStack{
                        Text("Welcome to\n").font(.system(size: 40))+Text("iPlay").font(.system(size: 40)).fontWeight(.bold)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top,-130)
                    
                    TextField("Enter Username", text: $username)
                        .padding()
                    
                        .frame(width:240,height:60)
                        .multilineTextAlignment(.center)
                        .background(
                            RoundedRectangle(cornerRadius: 30).fill(Color.clear)
                                .stroke(Color.black, lineWidth: 1)
                        )
#if os(iOS)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .ignoresSafeArea(.keyboard)
#endif
                    /*
                     This is needed since we are using a multiplatform app
                     so we need to check if os is iOS for disabling contextual
                     autocapitalization and autocorrect modifiers (QOL)
                     */
                    
//                    Button("Look For Lobbies") {
//                        MCPlayerManager.createSharedInstance(name: username)
//                        mcManager = MCPlayerManager.shared
//                        if let mcManager {
//                            mcManager.viewState = .preLobby
//                            mcManager.start()
//                        } else {
//                            print("MC Manager not initialized")
//                        }
//                    }
                    Button(action: {
                        MCPlayerManager.createSharedInstance(name: username)
                        mcManager = MCPlayerManager.shared
                        if let mcManager {
                            mcManager.viewState = .preLobby
                            mcManager.start()
                        } else {
                            print("MC Manager not initialized")
                        }
                    }) {
                        Text("Join game")
                            .font(.title2)
                            .foregroundColor(.white) // Text color
                            .frame(width: 240, height: 60) // Size of button
                            .background( // Button background color
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color.black, lineWidth: 1).fill(Color.black)
                                        .opacity((username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.2 : 1.0))
                            )
                    }
                    .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Button(action: {
                        isNavigating = true
                    }) {
                        Text("Customize Avatar")
                            .font(.title2)
                            .foregroundColor(.black) // Text color
                            .frame(width: 240, height: 60) // Size of button
                            .background(
                                RoundedRectangle(cornerRadius: 30).stroke( Color.black,lineWidth:1).fill(Color.gray)
                            ) // Button background color
                            
                    }
                    .navigationDestination(isPresented:$isNavigating){
                        AvatarView()
                        
                    }
                    
                    
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentViewiPhone()
}
