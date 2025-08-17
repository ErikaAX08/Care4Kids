//
//  UserTypeSelectionView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct UserTypeSelectionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    let authAction: AuthAction
    
    @State private var selectedUserType: UserType = .parent
    @State private var showAuthView = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 32) {
                        // Header con botón de retroceso
                        VStack(spacing: 16) {
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                        .font(.title2)
                                        .foregroundColor(Constants.Colors.primaryPurple)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            VStack(spacing: 8) {
                                Text("Antes de Empezar")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                
                                Text("Seleccione de quién es este dispositivo")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 20)
                        
                        // Selector de tipo de usuario
                        VStack(spacing: 16) {
                            ForEach(UserType.allCases, id: \.self) { userType in
                                UserTypeCard(
                                    userType: userType,
                                    isSelected: selectedUserType == userType
                                ) {
                                    selectedUserType = userType
                                    authViewModel.setUserType(userType)
                                    print("Tipo de usuario seleccionado: \(userType.displayName)")
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                        
                        // Botón continuar
                        CustomButton(
                            title: "Continuar",
                            style: .primary
                        ) {
                            print("Continuando con acción: \(authAction.title)")
                            showAuthView = true
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .fullScreenCover(isPresented: $showAuthView, onDismiss: {
            print("AuthView sheet cerrado")
        }) {
            if authAction == .login {
                LoginView()
                    .environmentObject(authViewModel)
            } else {
                RegisterView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            print("UserTypeSelectionView apareció para acción: \(authAction.title)")
            authViewModel.setUserType(selectedUserType)
        }
    }
}

// MARK: - UserTypeCard Component
struct UserTypeCard: View {
    let userType: UserType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icono
                ZStack {
                    Circle()
                        .fill(isSelected ? Constants.Colors.primaryPurple : Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: userType == .parent ? "person.fill" : "person.2.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                // Contenido
                VStack(alignment: .leading, spacing: 4) {
                    Text(userType.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)

                }
                
                Spacer()
                
                // Selector circular
                ZStack {
                    Circle()
                        .stroke(isSelected ? Constants.Colors.primaryPurple : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Constants.Colors.primaryPurple)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(20)
            .cardBackground(isSelected: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Extension para simplificar el background
extension View {
    func cardBackground(isSelected: Bool) -> some View {
        let shadowColor = isSelected ? Constants.Colors.primaryPurple.opacity(0.2) : Color.black.opacity(0.1)
        let shadowRadius: CGFloat = isSelected ? 8 : 4
        let strokeColor = isSelected ? Constants.Colors.primaryPurple : Color.clear
        
        return self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(strokeColor, lineWidth: 2)
            )
    }
}

// MARK: - AuthAction Enum
enum AuthAction: CaseIterable {
    case login
    case register
    
    var title: String {
        switch self {
        case .login:
            return "Iniciar Sesión"
        case .register:
            return "Registrarse"
        }
    }
}

#Preview {
    UserTypeSelectionView(authAction: .login)
        .environmentObject(AuthViewModel())
}
