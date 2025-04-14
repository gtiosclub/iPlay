//
//  LobbyView.swift
//  iPlay
//
//  Created by Ryan O’Meara on 4/14/25.
//

import SwiftUI

struct LobbyPhoneView: View {
    var avatar: String
    var username: String
    
    var body: some View {
        VStack {
            Text(username)
                .font(.system(size: 35))
                .bold()
                .padding(.vertical, 40)
            Image(avatar)
                .resizable()
                .scaledToFit()
                .frame(width:300, height:300)
        }
    }
}

#Preview {
    LobbyPhoneView(avatar:"BarrelSprite", username:"Test Name")
}
