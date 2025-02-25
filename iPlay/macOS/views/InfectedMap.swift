//
//  InfectedMap.swift
//  iPlay
//
//  Created by Hardik Kolisetty on 2/6/25.
//


import SwiftUI

struct Obstacle: Identifiable {
    let id = UUID()
    let shape: ShapeType
    let position: CGPoint
    let size: CGFloat
}

enum ShapeType: CaseIterable {
    case circle, rectangle
}

let mapsize = CGSize(width: 500, height: 500)
var obstacles: [Obstacle] = []

struct InfectedMap: View {
    var body: some View {
            ZStack {
                Color.green.opacity(0.1)
                    .frame(width: mapsize.width, height: mapsize.height)
                    .border(Color.black, width: 2)
                
                ForEach(obstacles) { obstacle in
                                getShape(for: obstacle)
                        .frame(width: obstacle.size, height: obstacle.size)
                        .position(obstacle.position)
                }
                
            }
            .onAppear(perform: generateObstacles)
        }
}

func generateObstacles() {
    let numberOfObstacles = Int.random(in: 3...7)
    var newObstacles: [Obstacle] = []
    
    for _ in 0..<numberOfObstacles {
        let shape = ShapeType.allCases.randomElement()!
        let size = CGFloat.random(in: 50...80)
        var position: CGPoint
        
        repeat {
            position = CGPoint(
                x: CGFloat.random(in: 100...(mapsize.width - 100)),
                y: CGFloat.random(in: 100...(mapsize.height - 100))
            )
        } while isTooClose(position, in: newObstacles)
        
        let obstacle = Obstacle(shape: shape, position: position, size: size)
        newObstacles.append(obstacle)
    }
    
    obstacles = newObstacles
}

func isTooClose(_ position: CGPoint, in obstacles: [Obstacle]) -> Bool {
    for obstacle in obstacles {
        let dx = position.x - obstacle.position.x
        let dy = position.y - obstacle.position.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 100 {
            return true
        }
    }
    return false
}

@ViewBuilder
func getShape(for obstacle: Obstacle) -> some View {
    switch obstacle.shape {
    case .circle:
        Circle().fill(Color.red)
    case .rectangle:
        Rectangle().fill(Color.blue)
    }
}

#Preview {
    InfectedMap()
}
