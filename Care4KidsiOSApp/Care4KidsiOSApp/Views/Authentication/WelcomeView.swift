//
//  WelcomeView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showUserTypeSelection = false
    @State private var selectedAction: AuthAction = .login
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                
                // Contenido principal
                VStack(spacing: 32) {
                    // Título de bienvenida
                    Text("Bienvenido a")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.black)
                    
                    // Logo Care4Kids
                    VStack(spacing: 8) {
                        HStack(spacing: 0) {
                            Text("care")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.primaryPurple)
                                .textCase(.lowercase)
                        }
                        
                        HStack(spacing: 0) {
                            Text("4")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.secondaryPink)
                            Text("kids")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.secondaryPink)
                                .textCase(.lowercase)
                        }
                    }
                    
                    // Descripción
                    Text("Con Care4Kids podrás supervisar, guiar y proteger la actividad digital de tus hijos de forma sencilla y segura, directamente desde tu smartphone.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Botones de acción
                VStack(spacing: 16) {
                    // Botón Iniciar Sesión
                    Button(action: {
                        print("Botón login presionado")
                        selectedAction = .login
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showUserTypeSelection = true
                        }
                    }) {
                        Text("Iniciar Sesión")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Constants.Colors.primaryPurple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    // Botón Registrarse
                    Button(action: {
                        print("Botón register presionado")
                        selectedAction = .register
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showUserTypeSelection = true
                        }
                    }) {
                        Text("Registrarse")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.primaryPurple)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .fullScreenCover(isPresented: $showUserTypeSelection, onDismiss: {
            print("UserTypeSelection sheet cerrado")
        }) {
            UserTypeSelectionView(authAction: selectedAction)
                .environmentObject(authViewModel)
        }
        .onAppear {
            print("WelcomeView apareció")
        }
    }
}
