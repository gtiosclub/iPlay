#if os(macOS)

import SwiftUI
import AppKit

struct EmojiMatchRoundOverView: View {
    @Binding var gameState: EmojiMatchMacState
    
    var body: some View {
        GeometryReader { context in
            ZStack {
                Image(.emojiMatchBackground)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    ForEach(Array(MCHostManager.shared!.gameParticipants), id: \.id) { player in
                        HStack {
                            Spacer()
                            
                            Image(player.avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                            
                            ZStack {
                                if let image = MCHostManager.shared!.emojiMatchImages[player.id] {
                                    ZStack {
                                        Image(nsImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150)
                                            .clipShape(Circle())
                                        
                                        Image("circleHolePaper")
                                            .resizable()
                                            .scaledToFit()
                                            .scaleEffect(1.6)
                                            .offset(y: 1)
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    }
                                    .frame(width: 150, height: 150)
                                }
                            }
                            
                            Text("\(MCHostManager.shared!.emojiMatchVotes[player.id, default: 0]) votes")
                                .foregroundStyle(.black)
                            
                            if let aiGuess = MCHostManager.shared!.emojiMatchAIVote, aiGuess == player.id {
                                Text("EmojiAI Voted for You!")
                                    .foregroundStyle(.black)
                            }

                            Spacer()
                            Spacer()
                        }
                    }
                }
                
                HStack {
                    VStack {
                        Button {
                            MCHostManager.shared!.viewState = .inLobby
                            MCHostManager.shared!.emojiMatchImages = [:]
                            MCHostManager.shared!.emojiMatchScores = [:]
                            MCHostManager.shared!.emojiMatchScores = [:]
                            MCHostManager.shared!.emojiMatchEmoji = .happy
                            MCHostManager.shared!.emojiMatchAIVote = .none
                        } label: {
                            Image(systemName: "x.circle")
                                .foregroundStyle(.black)
                                .imageScale(.large)
                        }
            
                        Spacer()
                        
                        Button {
                            MCHostManager.shared!.emojiMatchImages = [:]
                            MCHostManager.shared!.emojiMatchScores = [:]
                            MCHostManager.shared!.emojiMatchScores = [:]
                            MCHostManager.shared!.emojiMatchEmoji = .happy
                            MCHostManager.shared!.emojiMatchAIVote = .none
                            MCHostManager.shared!.sendEmojiMatchState(state: .start)
                            gameState = .inGame
                        } label: {
                            Text("Play Again?")
                        }
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#endif
