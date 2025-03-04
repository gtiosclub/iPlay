//
//  HintSubmittedView.swift
//  iPlay
//
//  Created by Danny Byrd on 3/3/25.
//

import SwiftUI

struct HintSubmittedView: View {
    var body: some View {
        VStack {
            Text("Hint Submitted!")
                .bold()
            Text("Waiting for guessers...")
        }
    }
}

#Preview {
    HintSubmittedView()
}
