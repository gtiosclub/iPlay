//
//  AvatarView.swift
//  iPlay
//
//  Created by Patrick Ying on 2/27/25.
//
#if os(iOS)
import SwiftUI

struct AvatarView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var username: String
    @Binding var avatar: String?
    
    var body: some View {
        ZStack {
            Image("iPhoneBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            Button(action: {
                dismiss()
            }, label: {
                Image("BackArrow")
                    .resizable()
                    .frame(width:50, height:50)
                    .aspectRatio(contentMode: .fill)
                    .position( x: 50, y: 70)
            }
            )
            
            VStack {
                HStack {
                    TextField("Enter Username", text: $username)
                        .font(.system(size:40))
                        .multilineTextAlignment(.center)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .ignoresSafeArea(.keyboard)
//                    Image("Pencil")
//                        .resizable()
//                        .frame(width:50,height:50)
//                        .aspectRatio(contentMode: .fit)
                }
                
                TabView(selection: $avatar) {
                                ForEach(avatars, id: \.self) { avatar in
                                    Image(avatar)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                        .padding()
                                        .tag(avatar)
                                }
                            }
                            .frame(height: 250)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .padding(.vertical, 40)

            }
        }
    }
}

//Preview
struct AvatarPreview: View {
    @State private var username = "Player1"
    @State private var avatar: String? = "BottleSprite"
    
    var body: some View {
        AvatarView(username: $username, avatar: $avatar)
    }
}
#Preview {
    AvatarPreview()
}
#endif
