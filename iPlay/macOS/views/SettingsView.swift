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
        
        Text("Settings")
            .font(.system(size: 50))
            .padding(50)
        
        Button(action: {
            dismiss()
        }, label: {
            Text("Back")
                .font(.title2)
                .foregroundColor(.black) // Text color
                .frame(width: 240, height: 60) // Size of button
                .background(
                    RoundedRectangle(cornerRadius: 30).stroke( Color.black,lineWidth:1).fill(Color.gray)
                ) // Button background color
            
        })    }
}

#Preview {
    SettingsView()
}
