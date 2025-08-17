import SwiftUI
import CoreLocation
import SafariServices
import UIKit
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSplash = true

    var body: some View {
        VStack(spacing: 0) {
            parentalControlHeader
            
            TabView(selection: $selectedTab) {
                AppListView()
                    .tabItem {
                        Image(systemName: "apps.iphone")
                        Text("Apps")
                    }
                    .tag(0)
                
                AppBlockingView()
                    .tabItem {
                        Image(systemName: "lock.shield")
                        Text("Bloqueos")
                    }
                    .tag(1)
                
                WebControlView()
                    .tabItem {
                        Image(systemName: "shield.fill")
                        Text("Web Control")
                    }
                    .tag(2)
                
                LocationView(locationManager: locationManager)
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text("Ubicación")
                    }
                    .tag(3)
                
                UsageLimitView()
                    .tabItem {
                        Image(systemName: "hourglass")
                        Text("Límites")
                    }
                    .tag(4)
            }
            .accentColor(.blue)
        }
        .environmentObject(appBlockingManager)
        .environmentObject(parentalControlManager)
        .sheet(isPresented: $showingParentalControl) {
            ParentalControlSetupView()
                .environmentObject(parentalControlManager)
                .environmentObject(appBlockingManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            appBlockingManager.checkForBlockedAppUsage()
        }
    }
    
    private var parentalControlHeader: some View {
        VStack(spacing: 10) {
            if parentalControlManager.isParentalControlEnabled {
                HStack {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Control Parental Activo")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Protección para \(parentalControlManager.childAge.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Configurar") {
                        showingParentalControl = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.green.opacity(0.3)),
                    alignment: .bottom
                )
            } else {
                HStack {
                    Image(systemName: "shield.slash")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Control Parental Inactivo")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Activa la protección para tu hijo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Activar Ahora") {
                        showingParentalControl = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.orange.opacity(0.3)),
                    alignment: .bottom
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
