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
                .bold()
            Text("Wait for the hint...")
        }
    }
}

#Preview {
    YouAreGuessingStartView()
}
