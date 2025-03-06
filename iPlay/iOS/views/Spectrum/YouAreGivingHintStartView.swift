//
//  YouAreGivingHintStartView.swift
//  iPlay
//
//  Created by Danny Byrd on 3/3/25.
//

import SwiftUI

struct YouAreGivingHintStartView: View {
    var body: some View {
        Text("You are giving the hint!")
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.black)
    }
}

#Preview {
    YouAreGivingHintStartView()
}
