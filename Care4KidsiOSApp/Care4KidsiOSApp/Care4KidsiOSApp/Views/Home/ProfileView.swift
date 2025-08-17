//
//  ProfileView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogoutAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 20) {
                    Text("Perfil")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Constants.Colors.darkGray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    // User profile card
                    VStack(spacing: 16) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Constants.Colors.primaryPurple, Constants.Colors.secondaryPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            if let user = authViewModel.currentUser {
                                Text(String(user.name.prefix(1)).uppercased())
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            if let user = authViewModel.currentUser {
                                Text(user.name)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                Text(user.email)
                                    .font(.system(size: 16))
                                    .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                                
                                Text(user.userType == .parent ? "Cuenta Padre" : "Cuenta Hijo")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Constants.Colors.primaryPurple)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Constants.Colors.primaryPurple.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .padding(.horizontal, 24)
                }
                
                // Profile options
                VStack(spacing: 16) {
                    ProfileOptionRow(
                        icon: "person.2.fill",
                        title: "Gestionar Hijos",
                        subtitle: "Agregar o editar perfiles de hijos",
                        color: .blue
                    ) {
                        // Acción para gestionar hijos
                    }
                    
                    ProfileOptionRow(
                        icon: "bell.fill",
                        title: "Notificaciones",
                        subtitle: "Configurar alertas y avisos",
                        color: .orange
                    ) {
                        // Acción para notificaciones
                    }
                    
                    ProfileOptionRow(
                        icon: "shield.fill",
                        title: "Privacidad y Seguridad",
                        subtitle: "Configuraciones de privacidad",
                        color: .green
                    ) {
                        // Acción para privacidad
                    }
                    
                    ProfileOptionRow(
                        icon: "questionmark.circle.fill",
                        title: "Ayuda y Soporte",
                        subtitle: "Centro de ayuda y FAQ",
                        color: .purple
                    ) {
                        // Acción para ayuda
                    }
                    
                    ProfileOptionRow(
                        icon: "info.circle.fill",
                        title: "Acerca de Care4Kids",
                        subtitle: "Versión 1.0.0",
                        color: Constants.Colors.darkGray
                    ) {
                        // Acción para información de la app
                    }
                }
                .padding(.horizontal, 24)
                
                // Logout section
                VStack(spacing: 16) {
                    Divider()
                        .padding(.horizontal, 24)
                    
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.red)
                            
                            Text("Cerrar Sesión")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Bottom spacing for TabView
                Spacer(minLength: 100)
            }
        }
        .background(Constants.Colors.lightGray.opacity(0.1))
        .alert("Cerrar Sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?")
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(color)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.darkGray)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
