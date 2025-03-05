//
//  ScoreboardScreen.swift
//  iPlay
//
//  Created by Karen Lu on 2/27/25.
//

import SwiftUI
import MultipeerConnectivity


struct ScoreboardScreen: View {
    
    var sortedPlayers: [Player] {
        MCHostManager.shared?.gameParticipants.sorted { $0.points > $1.points } ?? []
    }
    
    func rank(for players: Player) -> Int {
        if let index = sortedPlayers.firstIndex(of: players) {
            return index + 1
        }
        return 0
    }
    
    var body: some View {
            VStack(spacing: 0) {
                Text("Leaderboard")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                List(sortedPlayers, id: \.id) { player in
                    HStack {
                        Text("#\(rank(for: player))")
                            .font(.title2)
                            .bold()
                            .padding(.trailing, 10)
                        player.avatar
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    
                            Text(player.username)
                                .font(.headline)

                        Spacer()
                        Text("\(player.points) points")
                            .font(.headline)
                
                    }
                    .padding(.vertical, 8)
                }
                .listStyle(PlainListStyle())
                Button("Return to Lobby") {
                    MCHostManager.shared?.viewState = .inLobby
                }
            }
            .frame(maxWidth: .infinity, maxHeight:.infinity)
        }
    }


struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        let player1 = Player(id: MCPeerID(displayName: "Karen"),
                             username: "Karen",
                             avatar: Image(systemName: "person.fill"),
                             points: 100)
        let player2 = Player(id: MCPeerID(displayName: "Saahiti"),
                             username: "Saahiti123",
                             avatar:Image(systemName: "person.fill"),
                             points: 50)
        let player3 = Player(id: MCPeerID(displayName: "Shivani"),
                             username: "Shivani",
                             avatar: Image(systemName: "person.fill"),
                             points: 115)
        let player4 = Player(id: MCPeerID(displayName: "Ronit"),
                             username: "Ronit874",
                             avatar: Image(systemName: "person.fill"),
                             points: 12)
        ScoreboardScreen()
    }
}
