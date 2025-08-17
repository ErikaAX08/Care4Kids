//
//  AppManagementView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct AppManagementView: View {
    @State private var selectedChild = "Francisco I."
    @State private var searchText = ""
    
    // Datos simulados de los niños
    private let children = ["Francisco I.", "Erika A.", "Paul S.", "Juan C.", "Antonio F.", "Isabel N.", "Gloria S.", "Ricardo N."]
    
    // Datos simulados de apps instaladas
    @State private var installedApps: [AppInfo] = [
        AppInfo(name: "TikTok", category: "Redes Sociales", totalTime: "602 min", usageToday: "18 min", status: .blocked),
        AppInfo(name: "Instagram", category: "Redes Sociales", totalTime: "450 min", usageToday: "12 min", status: .blocked),
        AppInfo(name: "Facebook", category: "Redes Sociales", totalTime: "320 min", usageToday: "8 min", status: .blocked),
        AppInfo(name: "WhatsApp", category: "Redes Sociales", totalTime: "280 min", usageToday: "25 min", status: .allowed),
        AppInfo(name: "SnapChat", category: "Redes Sociales", totalTime: "180 min", usageToday: "5 min", status: .blocked)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con título
                VStack(spacing: 20) {
                    Text("Consejos para ti")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Constants.Colors.darkGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Tarjetas de consejos
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            AdviceCard(
                                image: "clock.fill",
                                color: .red,
                                category: "CONTROL DE TIEMPO DE PANTALLA",
                                title: "Establece horarios claros",
                                description: "Define un límite diario de uso del dispositivo. Por ejemplo: máximo 2 horas en días de escuela y 3 horas en fines de semana.",
                                buttonText: "Leer acerca de esto"
                            )
                            
                            AdviceCard(
                                image: "person.2.fill",
                                color: .blue,
                                category: "COMUNICACIÓN ABIERTA",
                                title: "Habla sobre lo que ven en internet",
                                description: "Pregunta a tus hijos qué videos, juegos o apps usan. Interésate en sus gustos y acompáñalos en su mundo digital.",
                                buttonText: "Leer acerca de esto"
                            )
                            
                            AdviceCard(
                                image: "shield.fill",
                                color: Constants.Colors.primaryPurple,
                                category: "SEGURIDAD EN REDES SOCIALES",
                                title: "Configura perfiles privados",
                                description: "Revisa junto a tu hijo la privacidad de sus cuentas y explícales por qué es importante aceptar solo a personas que conocen.",
                                buttonText: "Leer acerca de esto"
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // Sección de aplicaciones instaladas
                VStack(spacing: 20) {
                    // Título y selector de hijos
                    VStack(spacing: 16) {
                        Text("Aplicaciones instaladas en el teléfono de:")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.darkGray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        
                        // Selector de niños
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(children, id: \.self) { child in
                                    ChildSelectorButton(
                                        name: child,
                                        isSelected: selectedChild == child
                                    ) {
                                        selectedChild = child
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Texto explicativo
                        Text("Da click en el nombre de tus hijos para ver las estadísticas acerca de sus aplicaciones instaladas")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    // Estadísticas generales
                    HStack(spacing: 40) {
                        StatisticItem(
                            icon: "app.badge",
                            value: "5",
                            label: "Apps Instaladas"
                        )
                        
                        StatisticItem(
                            icon: "clock",
                            value: "602 min",
                            label: "Tiempo Total"
                        )
                        
                        StatisticItem(
                            icon: "star.fill",
                            value: "WhatsApp",
                            label: "Más Usada"
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Lista de aplicaciones
                    VStack(spacing: 12) {
                        ForEach(installedApps) { app in
                            AppRowView(app: app) { updatedApp in
                                if let index = installedApps.firstIndex(where: { $0.id == updatedApp.id }) {
                                    installedApps[index] = updatedApp
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .background(Color.white)
                
                Spacer()
            }
            .background(Constants.Colors.lightGray.opacity(0.3))
            .navigationBarHidden(true)
        }
    }
}

struct AdviceCard: View {
    let image: String
    let color: Color
    let category: String
    let title: String
    let description: String
    let buttonText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Imagen de fondo y categoría
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(height: 120)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(category)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 12)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
            }
            
            // Contenido de texto
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Constants.Colors.darkGray)
                    .lineLimit(2)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.8))
                    .lineLimit(3)
                
                Button(action: {}) {
                    Text(buttonText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Constants.Colors.primaryPurple)
                        .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 280)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ChildSelectorButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Constants.Colors.primaryPurple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Constants.Colors.primaryPurple : Constants.Colors.primaryPurple.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatisticItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Constants.Colors.primaryPurple)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Constants.Colors.darkGray)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
}

struct AppRowView: View {
    let app: AppInfo
    let onStatusChange: (AppInfo) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono de la app
            ZStack {
                Circle()
                    .fill(Constants.Colors.primaryPurple.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "app.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.Colors.primaryPurple)
            }
            
            // Información de la app
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.darkGray)
                
                Text(app.category)
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                
                Text("\(app.usageToday) hoy")
                    .font(.system(size: 12))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
            }
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 8) {
                Button(action: {
                    var updatedApp = app
                    updatedApp.status = app.status == .allowed ? .blocked : .allowed
                    onStatusChange(updatedApp)
                }) {
                    Text(app.status == .allowed ? "Abrir" : "Abrir")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Constants.Colors.primaryPurple)
                        .cornerRadius(16)
                }
                
                Button(action: {
                    var updatedApp = app
                    updatedApp.status = app.status == .limited ? .allowed : .limited
                    onStatusChange(updatedApp)
                }) {
                    Text("Limitar")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Constants.Colors.primaryPurple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Constants.Colors.primaryPurple.opacity(0.1))
                        .cornerRadius(16)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
}

// Modelo de datos para las aplicaciones
struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let totalTime: String
    let usageToday: String
    var status: AppStatus
}

enum AppStatus {
    case allowed
    case blocked
    case limited
    
    var color: Color {
        switch self {
        case .allowed:
            return .green
        case .blocked:
            return .red
        case .limited:
            return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .allowed:
            return "checkmark.circle.fill"
        case .blocked:
            return "xmark.circle.fill"
        case .limited:
            return "clock.circle.fill"
        }
    }
}

#Preview {
    AppManagementView()
}
