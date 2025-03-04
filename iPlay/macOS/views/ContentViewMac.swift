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
            NavigationStack {
                if let mcManager {
                    switch mcManager.viewState {
                    case .inLobby:
                        LobbyView(mcManager: mcManager, username: username)
                        
                    case .inGame:
                        //TODO: Fill in game selection and start of game
                        switch mcManager.gameState {
                        case .Infected:
                            Infected(mcManager: mcManager)
                                .onAppear {
                                    mcManager.startInfectedGame()
                                }
                            
                        case .Spectrum:
                            Text("Spectrum")
                        }
                    default:
                        Color.blue
                    }
                } else {
                    ZStack {
                        Color.white.edgesIgnoringSafeArea(.all)
                    VStack {
                        Image("MacHeader")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 500, height: 500)
                        TextField("Username", text: $username)
                            .padding()
                            .frame(width: 300)
                            .padding(.top, 30)
                        
                        Button(action: {
                            MCHostManager.createSharedInstance(name: username)
                            mcManager = MCHostManager.shared
                            if let mcManager {
                                mcManager.viewState = .inLobby
                                mcManager.gameState = .Infected
                                mcManager.start()
                            } else {
                                print("MC Manager not initialized")
                            }
                        }, label: {
                            HStack {
                                Image("startLobby")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 35, height: 35)
                                    .padding(.trailing, 20)
                                Text("start lobby")
                                    .font(.system(size: 32))
                                    .bold()
                            }
                        })
                        .buttonStyle(.plain)
                        .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .padding(.vertical, 5)
                        
                        NavigationLink {
                            SettingsView()
                        } label: {
                            HStack {
                                Image("settings")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 35, height: 35)
                                    .padding(.trailing, 20)
                                Text("settings")
                                    .font(.system(size: 32, weight: .ultraLight))
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 5)
                        
                        NavigationLink {
                            AboutView()
                        } label: {
                            HStack {
                                Image("about")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 35, height: 35)
                                    .padding(.trailing, 20)
                                Text("about")
                                    .font(.system(size: 32, weight: .ultraLight))
                                
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 5)
                    }
                }

                }
            }
            .preferredColorScheme(.light)
        
        
    }
}

#Preview {
    ContentViewMac()
}
