//
//  JoystickOverlay.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/6/25.
//

import SwiftUI

struct JoystickOverlay: View {
    @State private var movementVector: (CGFloat, CGFloat) = (0, 0)
    private var maxJoystickOffset: CGFloat = 60
    @State var timer: Timer?
    private var timerInterval = 0.1
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.black.opacity(0.3))
                .frame(width: 160, height: 160)
            Circle()
                .foregroundStyle(.black.opacity(0.7))
                .frame(width: 80, height: 80)
                .offset(x: movementVector.0, y: movementVector.1)
                .gesture(joystickDragGesture)
                
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { _ in
                sendMovementVector()
            })
        }
    }
    
    var joystickDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let center = CGPoint(x: 0, y: 0)
                let distance = center.distance(to: CGPoint(x: value.translation.width, y: value.translation.height))
                if distance > maxJoystickOffset {
                    let movementX = value.translation.width * maxJoystickOffset / distance
                    let movementY = value.translation.height * maxJoystickOffset / distance
                    movementVector = (movementX, movementY)
                } else {
                    movementVector = (value.translation.width, value.translation.height)
                }
                
               
            }
            .onEnded { _ in
                movementVector = (0, 0)
            }
    }
    func sendMovementVector() {
        let x = movementVector.0/maxJoystickOffset
        let y = movementVector.1/maxJoystickOffset
        if x == 0 && y == 0 {
            return
        }
        MCPlayerManager.shared?.sendVector(v: Vector(x: x, y: y))
        print("x: \(x), y: \(y)")
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
}

#Preview {
    JoystickOverlay()
}
