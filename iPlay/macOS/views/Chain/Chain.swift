//
//  Chain.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import SwiftUI
import Foundation
import SpriteKit
import NaturalLanguage

struct Chain: View {
    @ObservedObject var mcManager: MCHostManager
    @State var word: String = ""
    @State var wordChain: [String] = ["penguin"]
    let start = "penguin"
    let end = "desert"
    
    let threshold = 3.0
    
    var scene : SKScene {
        let scene = ChainGame()
        scene.size = CGSize(width:1280, height:800)
        scene.scaleMode = .aspectFill
        return scene
    }
    
    var body: some View {
        VStack {
            TextField(word, text: $word)
                .padding()
                .autocorrectionDisabled()
            Button(action:{
                addWord(word: word)
            }, label: { Text("Submit").padding()})
        }
    }
    
    func addWord(word: String) {
        if checkWordValidity(word: word) {
            wordChain.append(word)
            print(wordChain)
        } else {
            print("Word Rejected! Submit a word similar to \(wordChain[-1])")
        }
    }
    
    func checkWordValidity(word: String) -> Bool {
        let similarityScore = computeSimilarity(word_1: wordChain[-1], word_2: word)
        return similarityScore < threshold
    }
    
    func computeSimilarity(word_1: String, word_2: String) -> Double {
        if let embedding = NLEmbedding.wordEmbedding(for: .english) {
            let vectorA = embedding.vector(for: word_1)
            let vectorB = embedding.vector(for: word_2)
            
            var sum = 0.0
            
            for i in 0..<vectorA!.count {
                sum += (vectorA![i] - vectorB![i])*(vectorA![i] - vectorB![i])
            }
            let similarity = sqrt(sum)
            return similarity
        }
        return 5.0
    }
}


//#Preview {
//    Chain(mcManager: MCHostManager(name:))
//}
