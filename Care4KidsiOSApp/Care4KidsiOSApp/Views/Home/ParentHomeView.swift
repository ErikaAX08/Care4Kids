//
//  ParentHomeView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct ParentHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard principal
            ParentDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            // Controles parentales
            ParentControlsView()
                .tabItem {
                    Image(systemName: "shield.fill")
                    Text("Controles")
                }
                .tag(1)
            
            // Actividad de los niños
            ActivityView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Actividad")
                }
                .tag(2)
            
            // Configuración
            SettingsView()
                .tabItem {
                    Image(systemName: "gear.fill")
                    Text("Ajustes")
                }
                .tag(3)
        }
        .accentColor(Constants.Colors.primaryPurple)
    }
}

struct ParentDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("¡Hola!")
                                    .font(Constants.Fonts.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                if let user = authViewModel.currentUser {
                                    Text(user.name)
                                        .font(Constants.Fonts.subtitle)
                                        .foregroundColor(Constants.Colors.primaryPurple)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Constants.Colors.lightGray)
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(Constants.Colors.primaryPurple)
                                }
                            }
                        }
                        
                        // Estado general
                        StatusCard()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Tarjetas de funciones principales
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        FeatureCard(
                            icon: "person.2.fill",
                            title: "Dispositivos Conectados",
                            subtitle: "3 activos",
                            color: Constants.Colors.primaryPurple
                        )
                        
                        FeatureCard(
                            icon: "clock.fill",
                            title: "Tiempo de Pantalla",
                            subtitle: "2h 30m hoy",
                            color: Constants.Colors.secondaryPink
                        )
                        
                        FeatureCard(
                            icon: "shield.checkered",
                            title: "Sitios Bloqueados",
                            subtitle: "12 bloqueados",
                            color: .orange
                        )
                        
                        FeatureCard(
                            icon: "location.fill",
                            title: "Ubicación",
                            subtitle: "En casa",
                            color: .green
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Actividad reciente
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Actividad Reciente")
                                .font(Constants.Fonts.subtitle)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.darkGray)
                            
                            Spacer()
                            
                            Button("Ver todo") {
                                // Acción ver todo
                            }
                            .font(Constants.Fonts.caption)
                            .foregroundColor(Constants.Colors.primaryPurple)
                        }
                        
                        VStack(spacing: 12) {
                            ActivityRow(
                                icon: "globe",
                                title: "YouTube Kids",
                                time: "10:30 AM",
                                status: .allowed
                            )
                            
                            ActivityRow(
                                icon: "gamecontroller",
                                title: "Roblox",
                                time: "09:15 AM",
                                status: .blocked
                            )
                            
                            ActivityRow(
                                icon: "book",
                                title: "Khan Academy Kids",
                                time: "08:45 AM",
                                status: .allowed
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 100)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct StatusCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                    
                    Text("Todo está protegido")
                        .font(Constants.Fonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.darkGray)
                }
                
                Text("3 dispositivos monitoreados activamente")
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
        )
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.darkGray)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let time: String
    let status: ActivityStatus
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.lightGray)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Constants.Colors.darkGray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Constants.Fonts.body)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.darkGray)
                
                Text(time)
                    .font(Constants.Fonts.caption)
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(status.color.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Image(systemName: status.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(status.color)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Constants.Colors.lightGray.opacity(0.5))
        )
    }
}

enum ActivityStatus {
    case allowed
    case blocked
    
    var color: Color {
        switch self {
        case .allowed:
            return .green
        case .blocked:
            return .red
        }
    }
    
    var icon: String {
        switch self {
        case .allowed:
            return "checkmark"
        case .blocked:
            return "xmark"
        }
    }
}

// Views temporales para las otras pestañas
struct ParentControlsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Controles Parentales")
                    .font(Constants.Fonts.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .navigationTitle("Controles")
        }
    }
}

struct ActivityView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Actividad de los Niños")
                    .font(Constants.Fonts.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .navigationTitle("Actividad")
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Configuración")
                    .font(Constants.Fonts.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                CustomButton(title: "Cerrar Sesión", style: .secondary) {
                    authViewModel.logout()
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Ajustes")
        }
    }
}

#Preview {
    ParentHomeView()
        .environmentObject(AuthViewModel())
}
