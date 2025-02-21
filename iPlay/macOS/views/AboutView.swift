//
//  AboutView.swift
//  iPlay
//
//  Created by ananya jain on 2/20/25.
//



import SwiftUI

struct AboutView: View {
    @Binding var currentView: ViewState
    
    var body: some View {
        VStack {
            Text("hi this is the about page").padding()
            Button("Back") {
                currentView = .preLobby
            }
        }
    }
}
//
//#Preview {
//    AboutView()
//}
