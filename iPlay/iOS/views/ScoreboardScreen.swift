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
        ZStack {
            Image("lobbyBG")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                Text("Leaderboard")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .padding(.top, 100)
                
                ForEach(sortedPlayers) {player in
                    HStack {
                        Text("#\(rank(for: player))")
                            .font(.system(size: 45))
                            .bold()
                            .padding(.trailing, 15)
                        Image(player.avatar)
                            .resizable()
                            .frame(width: 80, height: 80)
                        
                        Text(player.username)
                            .font(.system(size:35))
                        
                        Spacer()
                        Text("\(player.points) points")
                            .font(.system(size:35))
                        
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 200)
                }
                
                Spacer()
                
                Button{
                    MCHostManager.shared?.viewState = .inLobby
                    MCHostManager.shared?.sendViewStateUpdate(MCHostManager.shared!.viewState)
                } label: {
                    ZStack {
                        Image("chooseGame")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300)
                            .opacity(0.6)
                        
                        Text("return to lobby")
                            .font(.system(size: 35))
                            .bold()
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 70)
            }
            }
            .frame(maxWidth: .infinity, maxHeight:.infinity)
        }
    }


struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        let player1 = Player(id: MCPeerID(displayName: "Karen"),
                             username: "Karen",
                             avatar: "BottleSprite",
                             points: 100)
        let player2 = Player(id: MCPeerID(displayName: "Saahiti"),
                             username: "Saahiti123",
                             avatar: "BottleSprite",
                             points: 50)
        let player3 = Player(id: MCPeerID(displayName: "Shivani"),
                             username: "Shivani",
                             avatar: "BottleSprite",
                             points: 115)
        let player4 = Player(id: MCPeerID(displayName: "Ronit"),
                             username: "Ronit874",
                             avatar:"BottleSprite",
                             points: 12)
        ScoreboardScreen()
    }
}
