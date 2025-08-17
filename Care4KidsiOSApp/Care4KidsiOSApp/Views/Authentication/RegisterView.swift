
//
//  RegisterView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//


import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptTerms = false
    
    // Estados para validación visual
    @State private var isNameValid = true
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    @State private var passwordsMatch = true
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header con navegación y título
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
                        }
                        .padding(.top, 20)
                        
                        // Formulario
                        VStack(spacing: 24) {
                            // Título principal
                            Text("Crear cuenta")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .padding(.bottom, 24)
                            
                            // Campo Nombre completo
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nombre completo")
                                    .font(Constants.Fonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                TextField("Ej. María López", text: $name)
                                    .padding()
                                    .background(Constants.Colors.lightGray)
                                    .cornerRadius(8)
                                    .font(Constants.Fonts.body)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isNameValid ? Color.clear : Color.red, lineWidth: 1)
                                    )
                                    .onChange(of: name) { newValue in
                                        isNameValid = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        authViewModel.errorMessage = ""
                                    }
                                
                                Text(isNameValid ? "Tu nombre aparecerá en tu perfil de padre/madre/tutor." : "El nombre es obligatorio")
                                    .font(Constants.Fonts.caption)
                                    .foregroundColor(isNameValid ? Constants.Colors.darkGray.opacity(0.7) : .red)
                            }
                            
                            // Campo Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(Constants.Fonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                TextField("marialopez@gmail.com", text: $email)
                                    .padding()
                                    .background(Constants.Colors.lightGray)
                                    .cornerRadius(8)
                                    .font(Constants.Fonts.body)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isEmailValid ? Color.clear : Color.red, lineWidth: 1)
                                    )
                                    .onChange(of: email) { newValue in
                                        isEmailValid = isValidEmail(newValue) || newValue.isEmpty
                                        authViewModel.errorMessage = ""
                                    }
                                
                                Text(isEmailValid ? "Usa un correo válido que revises con frecuencia" : "Ingresa un correo electrónico válido")
                                    .font(Constants.Fonts.caption)
                                    .foregroundColor(isEmailValid ? Constants.Colors.darkGray.opacity(0.7) : .red)
                            }
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(Constants.Fonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                SecureField("••••••••", text: $password)
                                    .padding()
                                    .background(Constants.Colors.lightGray)
                                    .cornerRadius(8)
                                    .font(Constants.Fonts.body)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                                    )
                                    .onChange(of: password) { newValue in
                                        isPasswordValid = isValidPassword(newValue) || newValue.isEmpty
                                        passwordsMatch = newValue == confirmPassword || confirmPassword.isEmpty
                                        authViewModel.errorMessage = ""
                                    }
                                
                                Text(isPasswordValid ? "Mínimo 8 caracteres, incluye una mayúscula y un número" : "La contraseña debe tener al menos 8 caracteres, una mayúscula y un número")
                                    .font(Constants.Fonts.caption)
                                    .foregroundColor(isPasswordValid ? Constants.Colors.darkGray.opacity(0.7) : .red)
                            }
                            
                            // Campo Confirmar contraseña
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirmar contraseña")
                                    .font(Constants.Fonts.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.darkGray)
                                
                                SecureField("••••••••", text: $confirmPassword)
                                    .padding()
                                    .background(Constants.Colors.lightGray)
                                    .cornerRadius(8)
                                    .font(Constants.Fonts.body)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(passwordsMatch ? Color.clear : Color.red, lineWidth: 1)
                                    )
                                    .onChange(of: confirmPassword) { newValue in
                                        passwordsMatch = newValue == password || newValue.isEmpty
                                        authViewModel.errorMessage = ""
                                    }
                                
                                Text(passwordsMatch ? "Debe coincidir con la contraseña anterior." : "Las contraseñas no coinciden")
                                    .font(Constants.Fonts.caption)
                                    .foregroundColor(passwordsMatch ? Constants.Colors.darkGray.opacity(0.7) : .red)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Mensaje de error
                        if !authViewModel.errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                
                                Text(authViewModel.errorMessage)
                                    .font(Constants.Fonts.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }
                        
                        // Botón Crear cuenta
                        VStack(spacing: 16) {
                            Button(action: {
                                authViewModel.register(
                                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                                    password: password,
                                    confirmPassword: confirmPassword
                                )
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        
                                        Text("Creando cuenta...")
                                            .font(Constants.Fonts.body)
                                            .fontWeight(.semibold)
                                    } else {
                                        Text("Crear cuenta")
                                            .font(Constants.Fonts.body)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(isFormValid && !authViewModel.isLoading ?
                                              Constants.Colors.primaryPurple :
                                              Constants.Colors.primaryPurple.opacity(0.6))
                                )
                            }
                            .disabled(!isFormValid || authViewModel.isLoading)
                            
                            // Link para iniciar sesión
                            Button(action: {
                                dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Text("¿Ya tienes cuenta?")
                                        .foregroundColor(Constants.Colors.primaryPurple)
                                    Text("Inicia sesión")
                                        .foregroundColor(Constants.Colors.primaryPurple)
                                        .fontWeight(.semibold)
                                }
                                .font(Constants.Fonts.body)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        
                        // Términos y condiciones (al final)
                        Text("Al continuar aceptas nuestros Términos y Condiciones.")
                            .font(Constants.Fonts.caption)
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 40)
                        
                        Spacer(minLength: 40)
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
        .onAppear {
            print("RegisterView apareció correctamente")
            authViewModel.errorMessage = ""
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                print("Usuario registrado exitosamente, cerrando RegisterView")
                dismiss()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               isValidEmail(email) &&
               isValidPassword(password) &&
               password == confirmPassword &&
               isNameValid && isEmailValid && isPasswordValid && passwordsMatch
    }
    
    // MARK: - Validation Methods
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let uppercaseRegex = ".*[A-Z]+.*"
        let numberRegex = ".*[0-9]+.*"
        
        let uppercasePredicate = NSPredicate(format: "SELF MATCHES %@", uppercaseRegex)
        let numberPredicate = NSPredicate(format: "SELF MATCHES %@", numberRegex)
        
        return uppercasePredicate.evaluate(with: password) &&
               numberPredicate.evaluate(with: password) &&
               password.count >= 8
    }
}

#if DEBUG
struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
#endif
