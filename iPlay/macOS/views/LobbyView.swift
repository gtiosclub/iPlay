//
//  LobbyView.swift
//  iPlay
//
//  Created by Ryan O’Meara on 2/7/25.
//

import SwiftUI
import SpriteKit

struct LobbyView: View {
    @ObservedObject var mcManager: MCHostManager
    var username: String
    
    var body: some View {
        VStack {
            Text("\(username)'s Lobby")
            List {
                ForEach(Array(mcManager.gameParticipants)) { player in
                    Section {
                        HStack {
                            Text(player.id.displayName)
                            Image(player.avatar)
                                .resizable()
                                .frame(width:65, height:65)
                                .aspectRatio(contentMode: .fit)
                                .padding(.leading, 30)
                        }
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
                    else if mcManager.gameState == .DogFight {
                        #if os(macOS)
                        createDogFightPlayers()
                        #endif
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
            mcManager.infectedPlayers.append(InfectedPlayer(id: player.id, name: player.id.displayName, isInfected: false, playerObject: SKSpriteNode(imageNamed: player.avatar)))
        }
        let randomIndex = Int.random(in: 0..<mcManager.infectedPlayers.count)
        mcManager.infectedPlayers[randomIndex].isInfected = true
        for player in mcManager.infectedPlayers {
            let infectedState = MCInfectedState(infected: player.isInfected, playerID: player.id.displayName)
            mcManager.sendInfectedState(infectedState)
        }
    }
    #if os(macOS)
    func createDogFightPlayers() {
        mcManager.dogFightPlayers.removeAll()

        var availableSprites = Array(planeSprites.keys).shuffled()
        
        
        for player in mcManager.gameParticipants {
            let spriteName = availableSprites.popLast() ?? "PlaneBlank"
            let sprite = SKSpriteNode(imageNamed: spriteName)
            let color = planeSprites[spriteName] ?? NSColor.white
            mcManager.dogFightPlayers.append(
                DogFightPlayer(id: player.id, name: player.id.displayName, playerObject: sprite, avatar: player.avatar, planeName: spriteName, color: color)
            )
        }
    }
    #endif
}

#Preview {
    LobbyView(mcManager: MCHostManager(name: "HostName"), username: "NoName")
}
