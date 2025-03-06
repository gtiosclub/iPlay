#if os(iOS)
import SwiftUI
import SpriteKit

struct YouAreGivingTheHintView: View {
    @State private var scene: SKScene
    @State private var hint = ""
    let prompt: SpectrumPrompt
    @Binding var mcPlayerManager: MCPlayerManager!

    init(prompt: SpectrumPrompt, playerManager: Binding<MCPlayerManager?>) {
        let newScene = ArrowComponent(size: CGSize(width: 400, height: 150))
        newScene.scaleMode = .resizeFill
        newScene.updateArrowPosition(for: CGFloat(prompt.num))
        newScene.setAreTouchesEnabled(to: false)
        newScene.backgroundColor = .clear

        _scene = State(initialValue: newScene)
        self.prompt = prompt
        _mcPlayerManager = playerManager
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("You are giving the hint")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
            
            SpriteView(scene: scene, options: .allowsTransparency)
                .frame(width: 300, height: 120)
                .background(Color.clear)

            Text("\(prompt.prompt)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
            
            TextField("Type your hint here", text: $hint)
                .foregroundStyle(.gray)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            Button("Submit") {
                mcPlayerManager.sendHint(hint)
                mcPlayerManager.spectrumPhoneState = .waitForGuessers
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

#endif
