//
//  TimerView.swift
//  iPlay
//
//  Created by Karen Lu on 2/6/25.
//

import SwiftUI
import MultipeerConnectivity

struct ScoreTracking: View {
    @ObservedObject var MCManager: MCHostManager
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(MCManager.infectedPlayers) { player in
                HStack(spacing: 8) {
                    Circle()
                        .fill(player.isInfected ? Color.red : Color.green)
                        .frame(width: 40, height: 40)
//                    player.avatar
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 40, height: 40)
//                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name)
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
    @ObservedObject var mcManager: MCHostManager
        
    var body: some View {
        Text("Time: \(String(format: "%.1f", 60 - mcManager.secondsElapsed))s")
            .font(.headline)
            .bold()
            .padding()
            .background(Color.gray.opacity(0.5))
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}
