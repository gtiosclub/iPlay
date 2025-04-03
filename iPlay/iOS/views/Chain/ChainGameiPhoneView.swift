//
//  ChainGameiPhoneView.swift
//  iPlay
//
//  Created by Josheev Rai on 3/25/25.
//

import Foundation


// MARK: - PlayerGuess (Model)

struct ChainLink: Identifiable {
    let id = UUID()
    let playerName: String
    let value: String
}
