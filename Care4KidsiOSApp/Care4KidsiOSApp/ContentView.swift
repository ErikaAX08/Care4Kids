//
//  ContentView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 16/08/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                if authViewModel.isAuthenticated {
                    HomeView()
                } else {
                    // Mostrar vista de bienvenida después del splash
                    WelcomeView()
                }
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
