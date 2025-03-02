import SwiftUI
import SpriteKit

struct YouAreGivingTheHintView: View {
    @State private var scene: SKScene
    @State private var hint = ""

    init(num: Int) {
        let newScene = ArrowComponent(size: CGSize(width: 400, height: 150))
        newScene.scaleMode = .resizeFill
        newScene.updateArrowPosition(for: CGFloat(num))
        newScene.setAreTouchesEnabled(to: false)

        _scene = State(initialValue: newScene)
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("You are giving the hint")
                .foregroundStyle(.black)
            SpriteView(scene: scene)
                .frame(width: 400, height: 150)
            
            TextField("Type your hint here", text: $hint)
                .foregroundStyle(.gray)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            Button("Submit") {
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
    }
}

#Preview {
    YouAreGivingTheHintView(num: .random(in: 0...10))
}
