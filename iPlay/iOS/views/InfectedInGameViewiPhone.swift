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
            JoystickOverlay()
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MCPlayerManager.shared!.currentInfectedStatus ? Color.red : Color.green)
    }
}

#Preview {
    InfectedInGameViewiPhone()
}
