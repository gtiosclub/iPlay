#if os(iOS)
import SpriteKit
import UIKit

struct ArrowComponentLogic {
    let center: CGPoint  // Center of the semicircular arc (bottom center of the scene)
    let radius: CGFloat

    // Returns a point on the semicircle for a given angle (in radians)
    func pointOnSemicircle(for angle: CGFloat) -> CGPoint {
        return CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    // Maps a value (0–10) to an angle on the semicircle.
    // Here, 0 corresponds to π (180°) and 10 corresponds to 0 (0°)
    func angle(forValue value: CGFloat) -> CGFloat {
        let fraction = value / 10.0
        return CGFloat.pi * (1 - fraction)
    }
}

class ArrowComponent: SKScene {
    private let arrow = SKSpriteNode(imageNamed: "arrow")
    private var logic: ArrowComponentLogic!
    private var areTouchesEnabled = true
    private var guess: CGFloat = 0.0
    
    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        let arcCenter = CGPoint(x: size.width / 2, y: 0)
        logic = ArrowComponentLogic(center: arcCenter, radius: 100)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAreTouchesEnabled(to touchesEnabled: Bool) {
        self.areTouchesEnabled = touchesEnabled
    }
    
    func getGuess() -> CGFloat {
        return guess
    }
    
    override func didMove(to view: SKView) {
        let arcCenter = CGPoint(x: size.width / 2, y: 0)
        
        backgroundColor = .white
        
        // Create and add the semicircle outline
        let semicircle = createSemicirclePath(center: arcCenter, radius: 110)
        addChild(semicircle)
        
        // Set arrow initial position
        let startAngle = CGFloat.pi / 2
        arrow.position = arcCenter
        arrow.zRotation = startAngle
        arrow.zPosition = 1
        addChild(arrow)
    }
    
    // Function to create a semicircle outline
    private func createSemicirclePath(center: CGPoint, radius: CGFloat) -> SKShapeNode {
        let path = UIBezierPath()
        path.addArc(
            withCenter: center,
            radius: radius,
            startAngle: .pi,
            endAngle: 0,
            clockwise: false
        )

        let shapeNode = SKShapeNode(path: path.cgPath)
        shapeNode.strokeColor = .white   // Outline color
        shapeNode.lineWidth = 2          // Outline thickness
        shapeNode.fillColor = .gray      // Fill the semicircle
        shapeNode.zPosition = 0          // Keep it behind the arrow
        return shapeNode
    }

    
    func updateArrowPosition(for value: CGFloat) {
        let angle = logic.angle(forValue: value)
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0.2, shortestUnitArc: true)
        arrow.run(rotateAction)
        guess = value
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard areTouchesEnabled else {
            return
        }
        handleTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard areTouchesEnabled else {
            return
        }
        handleTouch(touches)
    }
    
    private func handleTouch(_ touches: Set<UITouch>) {
        guard let location = touches.first?.location(in: self) else { return }
        
        let dx = location.x - logic.center.x
        let dy = location.y - logic.center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        var clickAngle = atan2(dy, dx)
        if clickAngle < 0 { clickAngle += 2 * CGFloat.pi }
        
        guard clickAngle <= CGFloat.pi else { return }
        
        let continuousValue = (1 - (clickAngle / CGFloat.pi)) * 10
        let nearestValue = round(continuousValue)
        
        updateArrowPosition(for: nearestValue)
    }
}

#endif
