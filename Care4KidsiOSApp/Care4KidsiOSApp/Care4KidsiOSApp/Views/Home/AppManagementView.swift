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
    
    // Datos simulados de apps instaladas con iconos e intentos de acceso
    @State private var installedApps: [AppInfo] = [
        AppInfo(name: "TikTok", category: "Redes Sociales", totalTime: "602 min", usageToday: "18 min", status: .blocked, iconName: "tiktok", accessAttempts: 23, lastAttempt: "Hace 15 min"),
        AppInfo(name: "Instagram", category: "Redes Sociales", totalTime: "450 min", usageToday: "12 min", status: .blocked, iconName: "instagram", accessAttempts: 18, lastAttempt: "Hace 32 min"),
        AppInfo(name: "Facebook", category: "Redes Sociales", totalTime: "320 min", usageToday: "8 min", status: .blocked, iconName: "facebook", accessAttempts: 12, lastAttempt: "Hace 1 hora"),
        AppInfo(name: "WhatsApp", category: "Redes Sociales", totalTime: "280 min", usageToday: "25 min", status: .allowed, iconName: "whatsapp", accessAttempts: 0, lastAttempt: nil),
        AppInfo(name: "SnapChat", category: "Redes Sociales", totalTime: "180 min", usageToday: "5 min", status: .blocked, iconName: "snapchat", accessAttempts: 8, lastAttempt: "Hace 2 horas")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header con título
                VStack(spacing: 20) {
                    HStack {
                        Text("Consejos para ti")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Constants.Colors.darkGray)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
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
                        HStack {
                            Text("Aplicaciones instaladas en el teléfono de:")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Constants.Colors.darkGray)
                            
                            Spacer()
                        }
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
                    
                    // Estadísticas generales mejoradas
                    HStack(spacing: 20) {
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
                            icon: "exclamationmark.triangle.fill",
                            value: "\(installedApps.filter { $0.status == .blocked }.reduce(0) { $0 + $1.accessAttempts })",
                            label: "Intentos Bloqueados"
                        )
                        
                        StatisticItem(
                            icon: "star.fill",
                            value: "WhatsApp",
                            label: "Más Usada"
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Lista de aplicaciones con separadores
                    VStack(spacing: 0) {
                        ForEach(Array(installedApps.enumerated()), id: \.element.id) { index, app in
                            AppRowView(app: app) { updatedApp in
                                if let appIndex = installedApps.firstIndex(where: { $0.id == updatedApp.id }) {
                                    installedApps[appIndex] = updatedApp
                                }
                            }
                            
                            // Separador entre apps (excepto la última)
                            if index < installedApps.count - 1 {
                                Divider()
                                    .background(Constants.Colors.darkGray.opacity(0.1))
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 24)
                }
                .background(Color.white)
                
                // Espaciado inferior para el TabView
                Spacer(minLength: 100)
            }
        }
        .background(Constants.Colors.lightGray.opacity(0.3))
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
            // Badge de estado rojo con el icono de la app
            ZStack {
                AppIconView(iconName: app.iconName, size: 60)
                
                // Badge de estado (X roja para bloqueadas) en la esquina superior izquierda
                if app.status == .blocked {
                    VStack {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 20, height: 20)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .offset(x: -8, y: -8)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            
            // Información de la app en el centro
            VStack(alignment: .leading, spacing: 4) {
                // Nombre de la app
                Text(app.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
                
                // Categoría
                Text(app.category)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                // Tiempo hoy e intentos en la misma línea
                HStack(spacing: 12) {
                    // Tiempo de uso
                    HStack(spacing: 2) {
                        Text(app.usageToday)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("hoy")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Intentos (solo para apps bloqueadas)
                    if app.status == .blocked && app.accessAttempts > 0 {
                        HStack(spacing: 2) {
                            Text("\(app.accessAttempts)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                            Text("intentos")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // Último intento (línea separada)
                if app.status == .blocked, let lastAttempt = app.lastAttempt {
                    Text("Último intento: \(lastAttempt)")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Botones en la derecha
            VStack(spacing: 8) {
                // Botón principal (Permitir/Bloquear)
                Button(action: {
                    var updatedApp = app
                    updatedApp.status = app.status == .allowed ? .blocked : .allowed
                    if updatedApp.status == .allowed {
                        updatedApp.accessAttempts = 0
                        updatedApp.lastAttempt = nil
                    }
                    onStatusChange(updatedApp)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text(app.status == .allowed ? "Bloquear" : "Permitir")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Constants.Colors.primaryPurple)
                    .cornerRadius(20)
                }
                
                // Botón secundario (Limitar)
                Button(action: {
                    var updatedApp = app
                    updatedApp.status = app.status == .limited ? .allowed : .limited
                    onStatusChange(updatedApp)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        
                        Text("Limitar")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Constants.Colors.primaryPurple)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(Constants.Colors.primaryPurple.opacity(0.1))
                    .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color.white)
    }
}

// Vista personalizada para mostrar iconos de apps
struct AppIconView: View {
    let iconName: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(backgroundColorForApp(iconName))
                .frame(width: size, height: size)
            
            Image(systemName: systemIconForApp(iconName))
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundColor(.white)
        }
    }
    
    // Función para obtener colores de fondo específicos por app
    private func backgroundColorForApp(_ iconName: String) -> Color {
        switch iconName.lowercased() {
        case "tiktok":
            return Color.black
        case "instagram":
            return Color.pink
        case "facebook":
            return Color.blue
        case "whatsapp":
            return Color.green
        case "snapchat":
            return Color.yellow
        default:
            return Constants.Colors.primaryPurple
        }
    }
    
    // Función para obtener iconos del sistema apropiados
    private func systemIconForApp(_ iconName: String) -> String {
        switch iconName.lowercased() {
        case "tiktok":
            return "music.note"
        case "instagram":
            return "camera.fill"
        case "facebook":
            return "person.2.fill"
        case "whatsapp":
            return "message.fill"
        case "snapchat":
            return "camera.viewfinder"
        default:
            return "app.fill"
        }
    }
}

// Modelo de datos actualizado para las aplicaciones
struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let totalTime: String
    let usageToday: String
    var status: AppStatus
    let iconName: String
    var accessAttempts: Int
    var lastAttempt: String?
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
