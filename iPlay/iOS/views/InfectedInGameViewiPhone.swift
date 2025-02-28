//
//  InGameViewiPhone.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/7/25.
//

import SwiftUI

struct InfectedInGameViewiPhone: View {
    var body: some View {
        VStack {
            Text("You are \(MCPlayerManager.shared!.currentInfectedStatus ? "" : "not") infected")
                .bold()
                .padding(.bottom, 80)
                .font(.system(size: 30))
                            
            JoystickOverlay()
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MCPlayerManager.shared!.currentInfectedStatus ? Color.red : Color.green)
    }
}

#Preview {
    InfectedInGameViewiPhone()
}
