//
//  GuessSubmittedView.swift
//  iPlay
//
//  Created by Danny Byrd on 3/3/25.
//

import SwiftUI

struct GuessSubmittedView: View {
    var body: some View {
        VStack {
            Text("Guess Submitted!")
                .bold()
            Text("Waiting for other guessers...")
        }
    }
}

#Preview {
    GuessSubmittedView()
}
