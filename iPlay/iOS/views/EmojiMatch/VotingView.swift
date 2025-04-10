//
//  VotingView.swift
//  iPlay
//
//  Created by Danny Byrd on 3/27/25.
//

import SwiftUI

struct VotingView: View {
    var body: some View {
        ZStack {
            Image(.iPhonePaperBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()

                Image(.cutoffPaper)
                    .overlay {
                        Text("Vote who\n matches the best!")
                            .font(.system(size: 30))
//                            .padding()
                            .multilineTextAlignment(.center)
                            .offset(y: -20)

                    }
                
                Spacer()
                
                
                
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    VotingView()
}
