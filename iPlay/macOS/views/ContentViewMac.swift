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
                VStack {
                    Text("\(username)'s Lobby")
                    List {
                        ForEach(Array(mcManager.gameParticipants)) { player in
                            Section {
                                Text(player.id.displayName)
                            }
                        }
                    }
                }
                
            case .inGame:
                //TODO: Fill in game selection and start of game
                Color.black
            default:
                Color.blue
            }
        } else {
            VStack {
                TextField("Username", text: $username)
                Button("Open Lobby") {
                    MCHostManager.createSharedInstance(name: username)
                    mcManager = MCHostManager.shared
                    if let mcManager {
                        mcManager.viewState = .inLobby
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
