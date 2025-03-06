//
//  YouAreGuessingStartView.swift
//  iPlay
//
//  Created by Danny Byrd on 3/3/25.
//

import SwiftUI

struct YouAreGuessingStartView: View {
    var body: some View {
        VStack {
            Text("You are guessing!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

            Text("Wait for the hint...")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.black)

        }
    }
}

#Preview {
    YouAreGuessingStartView()
}
