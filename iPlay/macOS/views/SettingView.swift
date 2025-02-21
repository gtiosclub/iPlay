//
//  SettingView.swift
//  iPlay
//
//  Created by ananya jain on 2/20/25.
//

import SwiftUI

struct SettingView: View {
    @Binding var currentView: ViewState
    
    var body: some View {
        VStack {
            Text("hello this is the settings").padding()
            Button("Back") {
                currentView = .preLobby
            }
        }
    }
}

//#Preview {
//    SettingView(currentView: <#T##Binding<ViewState>#>)
//}
