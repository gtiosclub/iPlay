//
//  TestSendView.swift
//  iPlay
//
//  Created by Josheev Rai on 2/6/25.
//

import SwiftUI
import MultipeerConnectivity

struct TestSendView: View {
    @State private var xValue: Double = 0
    @State private var yValue: Double = 0
    
    var body: some View {
        VStack {
            Text("Send a Vector to the Host")
                .font(.headline)
            
            HStack {
                Text("x:")
                TextField("X", value: $xValue, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }
            
            HStack {
                Text("y:")
                TextField("Y", value: $yValue, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }
            
            Button("Send Vector") {
                MCPlayerManager.shared?.sendVector(x: xValue, y: yValue)
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    TestSendView()
}
