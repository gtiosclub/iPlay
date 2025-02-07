//
//  InGameViewiPhone.swift
//  iPlay
//
//  Created by Степан Кравцов on 2/7/25.
//

import SwiftUI

struct InGameViewiPhone: View {
    @State var isInfected = false
    var body: some View {
        VStack {
            Text("You are \(isInfected ? "" : "not") infected")
                .bold()
            JoystickOverlay()
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isInfected ? Color.red : Color.green)
    }
}

#Preview {
    InGameViewiPhone()
}
