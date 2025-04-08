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
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("leaderboards")
                    
                ZStack {
                    Text("1.")
                        .offset(x: -88, y: -20)
                    HStack {
                        ForEach(0..<3) { _ in
                            self.circleFrame
                        }
                    }
                }
            }
            .rotationEffect(.degrees(-5))
            .offset(x: -154, y: -40)
            VStack {
                    
                ZStack {
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
                    .offset(x: -70, y: -40)
                    HStack {
                        ForEach(0..<3) { _ in
                            self.circleFrame
                                .scaleEffect(0.9)
                        }
                    }
                }
                Spacer()
                    .frame(height: 30)
                ZStack {
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
                    .offset(x: -70, y: -40)
                    HStack {
                        ForEach(0..<3) { _ in
                            self.circleFrame
                                .scaleEffect(0.9)
                        }
                    }
                }
                Spacer()
                    .frame(height: 30)
                ZStack {
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
                    .offset(x: -70, y: -40)
                    HStack {
                        ForEach(0..<3) { _ in
                            self.circleFrame
                                .scaleEffect(0.9)
                        }
                    }
                }
            }
            .rotationEffect(.degrees(3))
            .offset(x: 80, y: 10)
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
            .frame(width: 50, height: 50)
            .clipShape(Circle())
    }
}

#Preview {
    EmojiMatchLeaderboardView()
}
