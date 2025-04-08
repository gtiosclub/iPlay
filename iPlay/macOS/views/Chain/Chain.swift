//
//  Chain.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import SwiftUI
import Foundation
import NaturalLanguage

struct Chain: View {
    @ObservedObject var mcManager: MCHostManager

    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal) {
                HStack {
                    Text(formatChainText())
                        .font(.headline)
                        .padding()
                }
            }

            List(mcManager.chainLinks) { link in
                HStack {
                    Text(link.value)
                    Spacer()
                    Text(link.playerName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()
        }
        .padding()
    }

    func formatChainText() -> String {
        let words = mcManager.chainLinks.map { $0.value }
        return words.joined(separator: " → ")
    }
}



//#Preview {
//    Chain(mcManager: MCHostManager(name:))
//}
