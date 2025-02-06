//
//  iPlayApp.swift
//  iPlay
//
//  Created by Danny Byrd on 2/5/25.
//

import SwiftUI

@main
struct iPlayApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(iOS)
            ContentViewiPhone()
            #endif
            
            #if os(macOS)
            ContentViewMac()
            #endif
        }
    }
}
