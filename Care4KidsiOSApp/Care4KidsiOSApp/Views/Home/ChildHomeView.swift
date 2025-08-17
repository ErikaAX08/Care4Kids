//
//  ChildHomeView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct ChildHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard principal para niños
            ChildDashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            // Apps permitidas
            AppsView()
                .tabItem {
                    Image(systemName: "app.badge.fill")
                    Text("Apps")
                }
                .tag(1)
            
            // Mi tiempo
            MyTimeView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Mi Tiempo")
                }
                .tag(2)
            
            // Configuración básica
            ChildSettingsView()
                .tabItem {
                    Image(systemName: "gear.fill")
                    Text("Ajustes")
                }
                .tag(3)
        }
        .accentColor(Constants.Colors.secondaryPink)
    }
}

struct ChildDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header amigable para niños
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("¡Hola!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                if let user = authViewModel.currentUser {
                                    Text(user.name)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(Constants.Colors.secondaryPink)
                                }
                            }
                            
                            Spacer()
                            
                            // Avatar o emoji
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Constants.Colors.secondaryPink, Constants.Colors.primaryPurple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                
                                Text("😊")
                                    .font(.system(size: 30))
                            }
                        }
                        
                        // Tiempo restante de forma amigable
                        TimeRemainingCard()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Apps recomendadas o favoritas
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Tus Apps Favoritas")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.darkGray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(favoriteApps, id: \.id) { app in
                                    FavoriteAppCard(app: app)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Logros o insignias
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Mis Logros")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.darkGray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            AchievementCard(
                                emoji: "📚",
                                title: "Súper Lector",
                                description: "Leíste por 1 hora"
                            )
                            
                            AchievementCard(
                                emoji: "🎯",
                                title: "Buen Comportamiento",
                                description: "5 días sin advertencias"
                            )
                            
                            AchievementCard(
                                emoji: "⏰",
                                title: "Puntual",
                                description: "Respetas tus horarios"
                            )
                            
                            AchievementCard(
                                emoji: "🌟",
                                title: "Estrella Digital",
                                description: "Uso responsable"
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.white, Constants.Colors.lightGray.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
    }
}

struct TimeRemainingCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("⏰")
                        .font(.system(size: 24))
                    
                    Text("Tiempo de pantalla hoy")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Constants.Colors.darkGray)
                }
                
                HStack {
                    Text("Te quedan ")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                    + Text("1 hora 30 minutos")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.secondaryPink)
                }
            }
            
            Spacer()
            
            // Indicador circular de tiempo
            ZStack {
                Circle()
                    .stroke(Constants.Colors.lightGray, lineWidth: 6)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: 0.6) // 60% usado
                    .stroke(Constants.Colors.secondaryPink, lineWidth: 6)
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Constants.Colors.secondaryPink.opacity(0.1), Constants.Colors.primaryPurple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

struct FavoriteAppCard: View {
    let app: FavoriteApp
    
    var body: some View {
        VStack(spacing: 12) {
            // Icono de la app
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(app.color.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Text(app.emoji)
                    .font(.system(size: 36))
            }
            
            // Nombre de la app
            Text(app.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Constants.Colors.darkGray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 100)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

struct AchievementCard: View {
    let emoji: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 40))
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.darkGray)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.system(size: 12, design: .rounded))
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

// Modelo para apps favoritas
struct FavoriteApp: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let color: Color
}

let favoriteApps = [
    FavoriteApp(name: "YouTube Kids", emoji: "📺", color: .red),
    FavoriteApp(name: "Khan Academy Kids", emoji: "📚", color: .green),
    FavoriteApp(name: "Scratch Jr", emoji: "🎨", color: .orange),
    FavoriteApp(name: "Duolingo", emoji: "🦉", color: .green),
    FavoriteApp(name: "Minecraft Education", emoji: "⛏️", color: .brown)
]

// Views para las otras pestañas del niño
struct AppsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Mis Apps")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.darkGray)
                        .padding(.top, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(favoriteApps) { app in
                            AppGridCard(app: app)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct AppGridCard: View {
    let app: FavoriteApp
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(app.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Text(app.emoji)
                    .font(.system(size: 40))
            }
            
            Text(app.name)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Constants.Colors.darkGray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
}

struct MyTimeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Mi Tiempo")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.darkGray)
                    .padding(.top, 20)
                
                // Tiempo usado hoy
                VStack(spacing: 16) {
                    Text("Tiempo usado hoy")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Constants.Colors.darkGray)
                    
                    ZStack {
                        Circle()
                            .stroke(Constants.Colors.lightGray, lineWidth: 12)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: 0.6)
                            .stroke(Constants.Colors.secondaryPink, lineWidth: 12)
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text("1h 30m")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.secondaryPink)
                            
                            Text("de 2h 30m")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                        }
                    }
                }
                
                // Horarios
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mis Horarios")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Constants.Colors.darkGray)
                    
                    VStack(spacing: 8) {
                        ScheduleRow(time: "📱 Dispositivos", schedule: "8:00 AM - 8:00 PM")
                        ScheduleRow(time: "🎮 Juegos", schedule: "4:00 PM - 6:00 PM")
                        ScheduleRow(time: "📺 Videos", schedule: "6:00 PM - 7:00 PM")
                        ScheduleRow(time: "🌙 Dormir", schedule: "9:00 PM")
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct ScheduleRow: View {
    let time: String
    let schedule: String
    
    var body: some View {
        HStack {
            Text(time)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Constants.Colors.darkGray)
            
            Spacer()
            
            Text(schedule)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Constants.Colors.lightGray.opacity(0.5))
        )
    }
}

struct ChildSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Mis Ajustes")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Colors.darkGray)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    SettingRow(icon: "🔔", title: "Notificaciones", action: {})
                    SettingRow(icon: "🎨", title: "Personalizar", action: {})
                    SettingRow(icon: "❓", title: "Ayuda", action: {})
                    SettingRow(icon: "👨‍👩‍👧‍👦", title: "Contactar a papás", action: {})
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                CustomButton(
                    title: "Cerrar Sesión",
                    style: .secondary
                ) {
                    authViewModel.logout()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.system(size: 24))
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Constants.Colors.darkGray)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Constants.Colors.lightGray.opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ChildHomeView()
        .environmentObject(AuthViewModel())
}
