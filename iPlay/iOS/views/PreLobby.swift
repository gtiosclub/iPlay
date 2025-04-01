//
//  PreLobby.swift
//  iPlay
//
//  Created by Hardik Kolisetty on 3/27/25.
//

import SwiftUI

public struct PreLobby: View {
    let openLobbies: [Lobby]
    let playerCounter: Int
    let joinLobby: (Lobby) -> Void
    
    public var body: some View {
        ZStack{
            Image("IPhonePaperBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                // Back Button
                HStack {
                    Image("LeftArrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.leading, 30)
                
                // Player Icon
                VStack {
                    Text("Join a Game")
                        .font(.system(size: 32, weight: .medium))
                                        
                    Text("player 1")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, 1)
                    
                    Image("BarrelSprite")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 125, height: 125)
                }
                .padding(.bottom, 40)
                .padding(.top, 40)
                
                HStack {
                    Text("Lobbies")
                        .font(.system(size: 18, weight: .medium))
                    Image("globe")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 15)
                .padding(.leading, 10)
                
                
                // Lobbies
                VStack(spacing: 15) {
                    if openLobbies.isEmpty {
                        Text("Looking for lobbies...")
                            .padding(.top, 25)
                    } else {
                        ForEach(Array(openLobbies.enumerated()), id: \.element.id) { (index, lobby) in
                            LobbyRowView(
                                gameNum: index + 1,  // index starts from 0, so we add 1 to start from 1
                                hostName: lobby.id.displayName,
//                                playerCount: playerCounter,
//                                maxPlayers: 7,
                                onJoin: { joinLobby(lobby) }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                    
            }
        }
    }
        
}

struct LobbyRowView: View {
    var gameNum: Int
    var hostName: String
//    var playerCount: Int
//    var maxPlayers: Int
    var onJoin: () -> Void
    
    var body: some View {
        HStack {
            VStack {
                Text("Game \(gameNum)")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.leading, 20)
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Text("Hosted by:")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text(hostName)
                        .font(.system(size: 14, weight: .bold))
                        .padding(.leading, -3)
                }
                .padding(.bottom, 3)
                
//                HStack {
//                    Text("\(playerCount)/\(maxPlayers) players")
//                        .font(.system(size: 12, weight: .light))
//                        .foregroundColor(.black.opacity(0.8))
//                        .padding(.trailing, 5)
//                }
//                .padding(.trailing, 20)
                
            }
            
            Spacer()
            
            Button(action: onJoin) {
                Text("Join")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.black)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.black, lineWidth: 6)
                    .fill(Color(red: 241/255, green: 171/255, blue: 134/255))
            )
            .padding(.leading, 15)
            .padding(.trailing, 10)
        }
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(.black, lineWidth: 7)
                .fill(.white)
        )
    }
}
