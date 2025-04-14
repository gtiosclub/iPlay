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
        NavigationStack {
            ZStack {
                Image("lobbyBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Text("\(username)'s Lobby")
                        .font(.system(size:25))
                        .bold()
                        .padding(.top, 80)
                    
                        ForEach(Array(mcManager.gameParticipants)) { player in
                                HStack {
                                    Text(player.id.displayName)
                                        .font(.system(size:20))
                                    Image(player.avatar)
                                        .resizable()
                                        .frame(width:80, height:80)
                                        .aspectRatio(contentMode: .fit)
                                        .padding(.leading, 25)
                                }
                        }
                    
                    Spacer()
                    
                    NavigationLink{
                        GameSelectView(mcManager: mcManager)
                    } label: {
                            Text("choose game")
                                .font(.system(size: 30, weight: .thin))
                    }
                    .padding(.bottom, -25)
                    .buttonStyle(PlainButtonStyle())
                    
                        Button{
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
                        } label: {
                            ZStack {
                                Image("chooseGame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 300)
                                    .opacity(0.6)
                                
                                Text("start game")
                                    .font(.system(size: 35))
                                    .bold()
                            }
                        }
//                        .background(.blue)
                        .buttonStyle(PlainButtonStyle())
//                        .padding(.bottom, 40)
                        .disabled(mcManager.gameParticipants.count < 1)
                    }
                }
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
