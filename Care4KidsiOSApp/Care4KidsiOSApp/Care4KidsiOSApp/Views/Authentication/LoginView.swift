
//
//  LoginView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showRegisterView = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header con logo pequeño
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
                            
                            // Logo pequeño
                            HStack(spacing: 4) {
                                Text("Care")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Constants.Colors.primaryPurple)
                                + Text("4")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Constants.Colors.secondaryPink)
                                + Text("Kids")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Constants.Colors.primaryPurple)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 20)
                        
                        // Contenido principal
                        VStack(spacing: 32) {
                            // Título principal
                            Text("Inicia Sesión")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                            
                            // Formulario
                            VStack(spacing: 24) {
                                // Campo Email
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Correo Electrónico")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    TextField("ejemplo@correo.com", text: $email)
                                        .font(.system(size: 16))
                                        .padding(16)
                                        .background(Constants.Colors.lightGray)
                                        .cornerRadius(12)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .textInputAutocapitalization(.never) // iOS 15+
                                        .disableAutocorrection(true)
                                    
                                    Text("Usa el correo con el que te registraste")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                // Campo Contraseña
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Contraseña")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.black)
                                    
                                    SecureField("•••••••", text: $password)
                                        .font(.system(size: 16))
                                        .padding(16)
                                        .background(Constants.Colors.lightGray)
                                        .cornerRadius(12)
                                    
                                    Button(action: {
                                        // TODO: Implementar recuperación de contraseña
                                        print("Recuperar contraseña presionado")
                                    }) {
                                        Text("¿Olvidaste tu contraseña?")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            // Mensaje de error
                            if !authViewModel.errorMessage.isEmpty {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 16))
                                    
                                    Text(authViewModel.errorMessage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.leading)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal, 16)
                            }
                            
                            // Botón Iniciar Sesión
                            Button(action: {
                                // Limpiar errores previos
                                authViewModel.errorMessage = ""
                                
                                // Llamar al método de login del AuthViewModel
                                authViewModel.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                                  password: password)
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        
                                        Text("Iniciando sesión...")
                                            .font(.system(size: 18, weight: .semibold))
                                    } else {
                                        Text("Iniciar Sesión")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    authViewModel.isLoading ?
                                    Constants.Colors.primaryPurple.opacity(0.7) :
                                    Constants.Colors.primaryPurple
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                            .opacity((authViewModel.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                            
                            // Enlace de registro
                            Button(action: {
                                showRegisterView = true
                            }) {
                                VStack(spacing: 4) {
                                    Text("¿No tienes cuenta?")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Text("Regístrate aquí")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Constants.Colors.primaryPurple)
                                }
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 60)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .onTapGesture {
                // Ocultar teclado al tocar fuera de los campos
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                              to: nil, from: nil, for: nil)
            }
        }
        .fullScreenCover(isPresented: $showRegisterView) {
            RegisterView()
                .environmentObject(authViewModel)
        }
        .onAppear {
            print("LoginView apareció correctamente")
            // Limpiar mensajes de error al aparecer
            authViewModel.errorMessage = ""
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                print("Usuario autenticado exitosamente, cerrando LoginView")
                dismiss()
            }
        }
    }
}

// MARK: - Vista de prueba para desarrollo
#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
#endif
