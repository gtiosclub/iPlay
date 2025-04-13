//
//  EmojiMatchLeaderboardView.swift
//  iPlay
//
//  Created by Степан Кравцов on 4/8/25.
//

import SwiftUI

struct EmojiMatchLeaderboardView: View {
    var body: some View {
        ZStack {
            Image("overlappedPaperBg")
                .resizable()
                .scaledToFill()
            
            HStack {
                Spacer()
                
                VStack {
                    Spacer()
                    Spacer()
                    
                    Text("leaderboard")
                        .foregroundStyle(.black)
                        .font(.system(size: 50))
                    
                    ZStack {
                        VStack(spacing: 0) {
                            Text("1.")
                                .font(.system(size: 30))
                                .offset(x: -200)
                            
                            HStack {
                                ForEach(0..<3) { _ in
                                    ZStack {
                                        Image(EmojiTypes.happy.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                        self.circleFrame
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .rotationEffect(.degrees(-8))
                
                Spacer()
                
                VStack {
                    
                    ZStack {
                        VStack {
                            HStack {
                                Text("2.")
                                Image("BottleSprite")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("10 points")
                                    .font(.system(size: 10))
                                    .offset(x: -10)
                            }
                            .offset(x: -130)
                            HStack {
                                ForEach(0..<3) { _ in
                                    ZStack {
                                        Image(EmojiTypes.happy.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                        self.circleFrame
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 30)
                    ZStack {
                        
                        VStack {
                            HStack {
                                Text("3.")
                                Image("BlenderSprite")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("10 points")
                                    .font(.system(size: 10))
                                    .offset(x: -10)
                                
                            }
                            .offset(x: -130)
                            HStack {
                                ForEach(0..<3) { _ in
                                    ZStack {
                                        Image(EmojiTypes.happy.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                        self.circleFrame
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                        .frame(height: 30)
                    ZStack {
                        VStack {
                            HStack {
                                Text("4.")
                                Image("BowlSprite")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                Text("10 points")
                                    .font(.system(size: 10))
                                    .offset(x: -10)
                                
                            }
                            .offset(x: -130)
                            HStack {
                                ForEach(0..<3) { _ in
                                    ZStack {
                                        Image(EmojiTypes.happy.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                        self.circleFrame
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                Spacer()

            }
            .rotationEffect(.degrees(3))
        }
        .foregroundStyle(.black)
        .font(.system(size: 18))
    }
    
    var circleFrame: some View {
        Image("circleHolePaper")
            .resizable()
            .scaledToFit()
            .scaleEffect(1.6)
            .offset(y: 1)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
    }
}

#Preview {
    EmojiMatchLeaderboardView()
}
