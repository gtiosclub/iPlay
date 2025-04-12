//
//  EmojiMatchCameraView.swift
//  iPlay
//
//  Created by Danny Byrd on 4/10/25.
//

#if os(iOS)

import SwiftUI

struct EmojiMatchCameraView: View {
    @State private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            Image(.iPhonePaperBackground)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ZStack {
                    CameraView(image: $viewModel.currentFrame)
                        .frame(width: 250)
                        .clipShape(Circle())
                    
                    Image("circleHolePaper")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(1.6)
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                    
                    Button {
                        if let currentFrame = viewModel.currentFrame {
                            if MCPlayerManager.shared != nil {
                                MCPlayerManager.shared?.emojiMatchPhoneState = .pictureTaken
                                MCPlayerManager.shared?.emojiMatchPicture = currentFrame
                                MCPlayerManager.shared?.sendEmoijMatchPicture(cgImage: currentFrame)
                            } else {
                                print("No MCPLayerManager EmojiMatchCameraView")
                            }
                            
                            Task {
                                await runPrediction()
                            }
                        }
                    } label: {
                        Image(.emojiMatchCameraButton)
                    }
                    .offset(x: 0, y: 300)
                }
                
                Spacer()
            }
        }
    }
    
    func runPrediction() async {
        guard let mcManager = MCPlayerManager.shared else {
            print("No Player Manager")
            return
        }
        
        var emotion: String {
            switch mcManager.emojiMatchEmoji {
            case .happy:
                return "Happy"
            case .neutral:
                return "Neutral"
            case .suprised:
                return "Suprised"
            case .fear:
                return "Fear"
            case .angry:
                return "Angry"
            case .sad:
                return "Sad"
            case .none:
                return "Happy"
            }
        }
        
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let result = EmojiMatchModelView().makeModelPrediction(image: viewModel.currentFrame, targetEmotion: emotion)
                
                DispatchQueue.main.async {
                    print("Prediction result: \(result)")
                    MCPlayerManager.shared?.sendEmojiMatchConfidence(confidence: result)
                    continuation.resume()
                }
            }
        }
    }

}

#Preview {
    EmojiMatchCameraView()
}

#endif
