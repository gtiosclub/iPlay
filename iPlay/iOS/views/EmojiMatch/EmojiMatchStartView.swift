//
//  EmojiMatchStartView.swift
//  iPlay
//
//  Created by Danny Byrd on 4/10/25.
//

#if os(iOS)

import SwiftUI
import AVFoundation

struct EmojiMatchStartView: View {
    @Binding var mcManager: MCPlayerManager!
    
    var body: some View {
        ZStack {
            Image(.iPhonePaperBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            switch mcManager.emojiMatchPhoneState {
            case .start:
                Text("Get Ready to Take Your Picture!")
                    .foregroundStyle(.black)
            case .takingPicture:
                EmojiMatchCameraView()
            case .pictureTaken:
                VStack {
                    Text("Picture Submitted!")
                        .foregroundStyle(.black)
                    
                    Text("Waiting for others")
                        .foregroundStyle(.black)
                }
            case .voting:
                VotingView()
            case .scoreUpdate:
                Text("Check the screen to see who won!")
            case .voteSubmitted:
                Text("Vote Submitted!")
            }
        }
    }
}

#endif
