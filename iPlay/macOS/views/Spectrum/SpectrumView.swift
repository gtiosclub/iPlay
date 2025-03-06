//
//  SpectrumView.swift
//  iPlay
//
//  Created by Jason Nair on 3/3/25.
//

import SwiftUI

// MARK: - SpectrumView (Main Container)

struct SpectrumView: View {
    @ObservedObject var mcManager: MCHostManager
    
    @State private var hostRating: CGFloat = 0.5
    
    
    @State private var guesses: [PlayerGuess] = []
    
    
    @State private var countdown: Int = 30
    @State private var timer: Timer? = nil
    
    
    @State private var pointsAwarded: [String: Int] = [:]
    
    var body: some View {
        VStack {
            switch mcManager.spectrumGameState {
            case .whosPrompting:
                HinterHintingView(
                    hostRating: $hostRating,
                    onContinue: {
                        mcManager.sendSpectrumState(.guessing)
                        startCountdown()
                    }
                ).padding()
                
            case .guessing:
                if countdown > 0 {
                    GuessersGoView(
                        countdown: countdown,
                        onTimeUp: {
                            mcManager.sendSpectrumState(.revealingGuesses)
                            stopCountdown()
                        }
                    ).padding()
                } else {
                    TimeUpView {
                        mcManager.sendSpectrumState(.revealingGuesses)
                        guesses = generateSampleGuesses()
                    }.padding()
                }
            case .revealingGuesses:
                ResultsView(
                    hostRating: hostRating,
                    guesses: guesses,
                    onPointsAdded: {
                        pointsAwarded = calculatePoints(for: guesses, hostRating: hostRating)
                        mcManager.sendSpectrumState(.pointsAwarded)
                    }
                ).padding()
                
            case .pointsAwarded:
                PointsAddedView(
                    pointsAwarded: pointsAwarded,
                    onNewHinter: {
                        mcManager.sendOutInitialSpectrumData()
                    }
                ).padding()
                
            case .instructions:
                NewHinterView {
                    resetForNewRound()
                }.padding()
            default:
                Color.black
            }
        }
    }
    
    // MARK: - Timer Helpers
    func startCountdown() {
        countdown = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Sample Logic / Data
    
    func generateSampleGuesses() -> [PlayerGuess] {
        let sampleNames = ["Alice", "Bob", "Charlie", "Diana"]
        return sampleNames.map { name in
            PlayerGuess(playerName: name, value: .random(in: 0.0...1.0))
        }
    }
    
    
    func calculatePoints(for guesses: [PlayerGuess], hostRating: CGFloat) -> [String: Int] {
        var results: [String: Int] = [:]
        
        for guess in guesses {
            let distance = abs(guess.value - hostRating)
            results[guess.playerName] = (distance < 0.1) ? 10 : 0
        }
        return results
    }
    
    func resetForNewRound() {
        hostRating = 0.5
        guesses = []
        pointsAwarded = [:]
        countdown = 30
        //TODO: Switch to new prompter
    }
}

// MARK: - PlayerGuess (Model)

struct PlayerGuess: Identifiable {
    let id = UUID()
    let playerName: String
    let value: CGFloat
}

// MARK: - Subviews

struct HinterHintingView: View {
    @Binding var hostRating: CGFloat
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hinter is hinting! Get ready!")
                .font(.title2)
            
            DialWithSlider(value: $hostRating)
                .frame(height: 300)
            
            Button("Continue") {
                onContinue()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct GuessersGoView: View {
    let countdown: Int
    var onTimeUp: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Guessers go!")
                .font(.title2)
            Text("\(countdown)s left")
                .font(.headline)
            
            Text("Make your guesses now!")
            
            Button("Time’s up now") {
                onTimeUp()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct TimeUpView: View {
    var onShowResults: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Time’s up!")
                .font(.title)
                .foregroundColor(.red)
            
            Button("Show Results") {
                onShowResults()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct ResultsView: View {
    let hostRating: CGFloat
    let guesses: [PlayerGuess]
    var onPointsAdded: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Results")
                .font(.title)
        
            SpectrumResultsDial(hostRating: hostRating, guesses: guesses)
                .frame(height: 300)
            
            Button("Points Added") {
                onPointsAdded()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct PointsAddedView: View {
    let pointsAwarded: [String: Int]
    var onNewHinter: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Points Added!")
                .font(.title)
            
            ForEach(pointsAwarded.sorted(by: { $0.key < $1.key }), id: \.key) { playerName, points in
                Text("\(playerName): +\(points) points")
            }
            
            Button("Next Hinter") {
                onNewHinter()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct NewHinterView: View {
    var onStartNewRound: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Hinter!")
                .font(.title)
            Text("Pass the host role to the next player, or continue.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button("Start Next Round") {
                onStartNewRound()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

// MARK: - DialWithSlider (Host Setting a Rating)

struct DialWithSlider: View {
    @Binding var value: CGFloat  // 0..1
    
    var body: some View {
        VStack {
           
            ZStack {
                HalfCircleGradient()
                    .frame(width: 300, height: 150)
                
                
                ArrowPointer(value: value, radius: 75)
            }
            .frame(width: 300, height: 150)

            Slider(value: $value, in: 0...1)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - SpectrumResultsDial (Arcs for guesses + host arrow)

/// A dial that shows each guess as a colored arc, plus the host’s arrow.
struct SpectrumResultsDial: View {
    let hostRating: CGFloat
    let guesses: [PlayerGuess]
    
    var body: some View {
        ZStack {
            HalfCircleGradient()
                .frame(width: 300, height: 150)
           
            ForEach(guesses.indices, id: \.self) { i in
                let guess = guesses[i]
                let arcSize: CGFloat = 0.02
                let start = guess.value - arcSize/2
                let end   = guess.value + arcSize/2
                let from = min(max(start, 0), 1)
                let to   = min(max(end, 0), 1)
                
                HalfCircleArc(startFraction: from, endFraction: to)
                    .fill(guessColor(i))
                    .frame(width: 300, height: 150)
            }
            
            ArrowPointer(value: hostRating, radius: 75)
        }
        .frame(width: 300, height: 150)
    }
    
    func guessColor(_ index: Int) -> Color {
        let colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple]
        return colors[index % colors.count]
    }
}

// MARK: - Shapes & Helpers

struct HalfCircleGradient: View {
    var body: some View {
        Circle()
            .trim(from: 0.5, to: 1.0)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}


struct HalfCircleArc: Shape {
    let startFraction: CGFloat
    let endFraction: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        
        let startAngle = Angle(degrees: 180 + 180 * Double(startFraction))
        let endAngle   = Angle(degrees: 180 + 180 * Double(endFraction))
        
        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.width / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}

struct ArrowPointer: View {
    let value: CGFloat
    let radius: CGFloat  
    
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: 2, height: radius)
            .offset(y: -radius/2)
            .rotationEffect(.degrees(Double(value) * 180 - 90))
            .animation(.easeInOut, value: value)
    }
}

// MARK: - A Simple Button Style for Consistency

struct SpectrumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 120)
            .background(Color.blue.opacity(configuration.isPressed ? 0.5 : 0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// MARK: - Preview

struct SpectrumView_Previews: PreviewProvider {
    static var previews: some View {
        SpectrumView(mcManager: .init(name: "Danny"))
    }
}

