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
    
    @State private var countdown: Int = 30
    @State private var timer: Timer? = nil
    
    
    @State private var pointsAwarded: [String: Int] = [:]
    
    var body: some View {
        ZStack {
            Image(.spectrumBackground)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
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
                        )
                        .padding()
                        .onAppear {
                            startCountdown()
                        }
                    } else {
                        TimeUpView {
                            mcManager.sendSpectrumState(.revealingGuesses)
                        }.padding()
                    }
                case .revealingGuesses:
                    ResultsView(
                        hostRating: CGFloat(mcManager.spectrumPrompt?.num ?? 0) / 10.0,
                        guesses: mcManager.spectrumGuesses,
                        onPointsAdded: {
                            pointsAwarded = calculatePoints(for: mcManager.spectrumGuesses, hostRating: CGFloat(mcManager.spectrumPrompt?.num ?? 0) / 10.0)
                            mcManager.sendSpectrumState(.pointsAwarded)
                        }
                    ).padding()
                        .onAppear {
                            stopCountdown()
                        }
                    
                case .pointsAwarded:
                    PointsAddedView(
                        mcManager: mcManager, pointsAwarded: pointsAwarded,
                        onNewHinter: {
                            resetForNewRound()
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
        countdown = 30
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
            let distance = abs(guess.value - CGFloat(mcManager.spectrumPrompt?.num ?? 0) / 10.0)
            results[guess.playerName] = (distance < 0.2) ? 10 : 0
        }
        return results
    }
    
    func resetForNewRound() {
        mcManager.spectrumGuesses = []
        mcManager.spectrumPrompt = nil
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
        VStack() {
            Text("Hinter is hinting! Get ready!")
                .font(.system(size: 40, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            HalfCircleGradient()
                .frame(height: 500)

            
//            DialWithSlider(value: $hostRating)
//                .frame(height: 300)
            
//            Button("Continue") {
//                onContinue()
//            }
//            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct GuessersGoView: View {
    let countdown: Int
    var onTimeUp: () -> Void
    
    var body: some View {
        VStack {
            Text("Guessers go!")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text("\(countdown)s left")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
            HalfCircleGradient()
                .frame(height: 500)
            
            Text("Make your guesses now!")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            
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
        VStack {
            Text("Results")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        
            SpectrumResultsDial(hostRating: hostRating, guesses: guesses)
                .frame(height: 500)
            
            Button("Points Added") {
                onPointsAdded()
            }
            .buttonStyle(SpectrumButtonStyle())
        }
    }
}

struct PointsAddedView: View {
    @ObservedObject var mcManager: MCHostManager
    let pointsAwarded: [String: Int]
    var onNewHinter: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Text("Points Added!")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                ForEach(pointsAwarded.sorted(by: { $0.key < $1.key }), id: \.key) { playerName, points in
                    HStack {
                        Text("\(playerName): +\(points) points")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        if points == 0 {
                            Text("😭")
                                .font(.system(size: 20))
                        } else {
                            Text("💪")
                                .font(.system(size: 20))
                        }
                    }
                }
                
                Button("Next Hinter") {
                    onNewHinter()
                    mcManager.sendOutInitialSpectrumData()
                }
                .buttonStyle(SpectrumButtonStyle())
                
                Button("Return to lobby") {
                    onNewHinter()
                    mcManager.viewState = .inLobby
                }
                .buttonStyle(SpectrumButtonStyle())
            }
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

//struct DialWithSlider: View {
//    @Binding var value: CGFloat  // 0..1
//    
//    var body: some View {
//        VStack {
//            ZStack {
//                HalfCircleGradient()
//                    .frame(height: 500)
//                
//                
//                ArrowPointer(value: value, radius: 75)
//            }
//            .frame(width: 300, height: 150)
//
//            Slider(value: $value, in: 0...1)
//                .padding(.horizontal, 40)
//        }
//    }
//}

// MARK: - SpectrumResultsDial (Arcs for guesses + host arrow)

/// A dial that shows each guess as a colored arc, plus the host’s arrow.
struct SpectrumResultsDial: View {
    let hostRating: CGFloat
    let guesses: [PlayerGuess]
    
    var body: some View {
        ZStack {
            HalfCircleGradient()
    
            ArrowPointer(value: hostRating, radius: 210, name: "Prompt", color: .black)
            
            ForEach(guesses.indices, id: \.self) { i in
                ArrowPointer(value: guesses[i].value, radius: 180, name: guesses[i].playerName, color: .green)
                    .foregroundStyle(guessColor(i))
            }
//            
//            ForEach(guesses.indices, id: \.self) { i in
//                            let guess = guesses[i]
//                            let arcSize: CGFloat = 0.02
//                            let start = guess.value - arcSize/2
//                            let end   = guess.value + arcSize/2
//                            let from = min(max(start, 0), 1)
//                            let to   = min(max(end, 0), 1)
//                            
//                            HalfCircleArc(startFraction: from, endFraction: to)
//                                .fill(guessColor(i))
//                                .frame(width: 300, height: 150)
//                        }
        }
        .onAppear {
            print("GUESSES: \(guesses.count)")
            for guess in guesses {
                print(guess.value)
            }
        }
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
                .white
            )
            .stroke(.black, lineWidth: 5)
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
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            if name != "Prompt" {
                Text(name)
                    .foregroundStyle(color)
            }
            
            Triangle()
                .fill(color)
                .frame(width: 20, height: 15) // Adjust size as needed
            
            Rectangle()
                .fill(color)
                .frame(width: 4, height: radius)
        }
        .offset(y: -radius / 2) // Center the arrow properly
        .rotationEffect(.degrees(Double(value) * 180 - 90))
        .animation(.easeInOut, value: value)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Top
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // Bottom left
        path.closeSubpath()
        return path
    }
}

// MARK: - A Simple Button Style for Consistency

struct SpectrumButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 120)
            .background(Color.black.opacity(configuration.isPressed ? 0.5 : 0.8))
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

