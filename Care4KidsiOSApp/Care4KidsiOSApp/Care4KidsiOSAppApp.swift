//
//  Care4KidsiOSAppApp.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 16/08/25.
//

import SwiftUI

@main
struct Care4KidsiOSAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
