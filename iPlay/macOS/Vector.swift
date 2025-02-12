//
//  Vector.swift
//  iPlay
//
//  Created by Rexxwell Tendean on 2/12/25.
//

import Foundation

/// Struct representing a 2D vector that controls where the ball should go to.
struct Vector: Codable {
    /// Controls where the ball is going in the x-direction.
    let x: Double
    /// Controls where the ball is going in the y-direction.
    let y: Double
}
