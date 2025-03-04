//
//  SettingsView.swift
//  iPlay
//
//  Created by Ryan O’Meara on 3/3/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack {
            Text("Settings")
                .font(.system(size: 50))
                .padding(50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
}
