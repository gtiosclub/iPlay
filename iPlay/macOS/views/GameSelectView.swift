//
//  GameSelectionView.swift
//  iPlay
//
//  Created by Patrick Ying on 4/12/25.
//

import SwiftUI


struct GameSelectView: View {
    @ObservedObject var mcManager: MCHostManager
    
    var body: some View {
            ZStack {
                Image("gameSelectionBG")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Text("choose a game!")
                        .font(.system(size: 45))
                        .padding(.top, 120)
                    
                    Spacer()
                    
                    HStack {
                        Button {
                            print("random")
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        Color.clear, lineWidth: 4)
                                    .background(Image("randompic")
                                        .resizable())
                                    .frame(width: 400, height: 260)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            mcManager.gameState = .Infected
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        mcManager.gameState == .Infected ? Color.blue : Color.clear, lineWidth: 4)
                                    .background(Image("infectedpic")
                                        .resizable())
                                    .frame(width: 400, height: 260)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            mcManager.gameState = .Spectrum
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        mcManager.gameState == .Spectrum ? Color.blue : Color.clear, lineWidth: 4)
                                    .background(Image("spectrumpic")
                                        .resizable())
                                    .frame(width: 400, height: 260)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        }
                    .padding(.bottom, 20)
                    
                    HStack {
                        Button {
                            mcManager.gameState = .DogFight
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        mcManager.gameState == .DogFight ? Color.blue : Color.clear, lineWidth: 4)
                                    .background(Image("dogfight")
                                        .resizable())
                                    .frame(width: 400, height: 260)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            mcManager.gameState = .Chain
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        mcManager.gameState == .Chain ? Color.blue : Color.clear, lineWidth: 4)
                                    .background(Image("game4")
                                        .resizable())
                                    .frame(width: 400, height: 260)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button {
                            mcManager.gameState = .EmojiMatch
                        } label: {
                            ZStack{
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(
                                        mcManager.gameState == .EmojiMatch ? Color.blue : Color.clear, lineWidth: 4)
                                    .background(Image("game5")
                                        .resizable())
                                    .frame(width: 400, height: 260)
                                    .clipped()
                                    .shadow(radius: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            }
        }
}

#Preview {
    GameSelectView(mcManager: MCHostManager(name: "HostName"))
}
