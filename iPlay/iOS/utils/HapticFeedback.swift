//
//  HapticFeedback.swift
//  iPlay
//
//  Created by Jason Nair on 2/18/25.
//

import SwiftUI
import UIKit  

struct HapticFeedback {
    
    static func trigger(_ type: HapticType) {
        let generator: UIFeedbackGenerator
        
        switch type {
        case .light:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .medium:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        case .success:
            generator = UINotificationFeedbackGenerator()
            (generator as! UINotificationFeedbackGenerator).notificationOccurred(.success)
            return
        case .warning:
            generator = UINotificationFeedbackGenerator()
            (generator as! UINotificationFeedbackGenerator).notificationOccurred(.warning)
            return
        case .error:
            generator = UINotificationFeedbackGenerator()
            (generator as! UINotificationFeedbackGenerator).notificationOccurred(.error)
            return
        }
        
        (generator as! UIImpactFeedbackGenerator).prepare()
        (generator as! UIImpactFeedbackGenerator).impactOccurred()
    }
    
    enum HapticType {
        case light, medium, heavy
        case success, warning, error
    }
}


