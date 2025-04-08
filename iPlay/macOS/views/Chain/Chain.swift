//
//  Chain.swift
//  iPlay
//
//  Created by Jaoson Nair on 4/8/25.
//

import SwiftUI
import Foundation
import SpriteKit
import NaturalLanguage

struct Chain: View {
    @ObservedObject var mcManager: MCHostManager
    
    var body: some View {
        // Use the new ChainView implementation
        ChainView(mcManager: mcManager)
    }
}

// If ChainLink is not defined elsewhere, uncomment this:
// struct ChainLink: Identifiable {
//     let id = UUID()
//     let playerName: String
//     let value: String
// }

#Preview {
    Chain(mcManager: MCHostManager(name: "PreviewHost"))
}
