import SwiftUI
import CoreLocation
import SafariServices
import UIKit
import UserNotifications

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        // Simular tiempo de carga del splash
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSplash = false
                        }
                    }
            } else {
                if authViewModel.isAuthenticated {
                    // Usuario autenticado - mostrar HomeView que decidirá entre Parent/Child
                    HomeView()
                        .environmentObject(authViewModel)
                } else {
                    // Usuario no autenticado - mostrar WelcomeView
                    WelcomeView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
