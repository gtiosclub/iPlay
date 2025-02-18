//
//  TimerView.swift
//  iPlay
//
//  Created by Karen Lu on 2/6/25.
//

import SwiftUI
import MultipeerConnectivity

struct ScoreTracking: View {
    let players: [Player]
    var body: some View {
        HStack(spacing: 12) {
            ForEach(players) { player in
                HStack(spacing: 8) {
                    player.avatar
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.username)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(player.points) pts")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
//        .background(Color.gray.opacity(0.4))
    }
}

struct TimerView: View {
    @State private var secondsElapsed: Double = 0.0
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
        
    var body: some View {
        Text("Time: \(String(format: "%.1f", 60 - secondsElapsed))s")
            .font(.headline)
            .bold()
            .padding()
            .background(Color.gray.opacity(0.5))
            .cornerRadius(8)
            .foregroundColor(.white)
            .onReceive(timer) { _ in
                if secondsElapsed <= 60{
                    secondsElapsed += 0.1
                }
            }
    }
}
struct ContentView: View {
    @State private var players: [Player] = [
            Player(
                id: MCPeerID(displayName: "Karen"),
                username: "Karen",
                avatar: Image("avatar1"),
                points: 123
            ),
            Player(
                id: MCPeerID(displayName: "Saahiti"),
                username: "Saahiti",
                avatar: Image("avatar2"),
                points: 456
            )
        ]
        
        var body: some View {
            VStack {
                Spacer()
                TimerView()
                    .padding(.bottom, 10)
                ScoreTracking(players: players)
                    .padding(.bottom, 20)
            }
            .background(Color("GameBackground").edgesIgnoringSafeArea(.all))
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

