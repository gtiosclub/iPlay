//
//  InGameViewiPhone.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/7/25.
//

import SwiftUI

struct InfectedInGameViewiPhone: View {
    @State var isInfected = false
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("You are \(isInfected ? "" : "not") infected")
                .bold()
                .padding(.bottom, 80)
                .font(.system(size: 30))
                
            
            JoystickOverlay()
            
            Spacer()
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isInfected ? Color.red : Color.green)
    }
}

#Preview {
    InfectedInGameViewiPhone()
}
