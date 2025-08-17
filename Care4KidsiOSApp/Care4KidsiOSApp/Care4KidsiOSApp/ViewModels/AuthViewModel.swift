//
//  AuthViewModel.swift
//  Care4KidsiOSApp
//
//  Updated by Erika Amastal on 17/08/25.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var authState: AuthenticationState = .idle
    @Published var selectedUserType: UserType = .parent
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let authService = AuthService()
    
    var isAuthenticated: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }
    
    var currentUser: User? {
        if case .authenticated(let user) = authState {
            return user
        }
        return nil
    }
    
    init() {
        // Verificar estado de autenticación al inicializar
        checkAuthenticationStatus()
    }
    
    // MARK: - Check Authentication Status
    func checkAuthenticationStatus() {
        print("🔍 AuthViewModel: Verificando estado de autenticación...")
        authState = .loading
        isLoading = true
        
        // Verificar si hay usuario y token guardados
        if let savedUser = authService.getSavedUser(), authService.isTokenValid() {
            print("✅ AuthViewModel: Usuario autenticado encontrado")
            authState = .authenticated(savedUser)
            isLoading = false
        } else {
            print("❌ AuthViewModel: No hay sesión activa")
            authState = .unauthenticated
            isLoading = false
        }
    }
    
    // MARK: - Set User Type
    func setUserType(_ type: UserType) {
        selectedUserType = type
        print("👤 AuthViewModel: Tipo de usuario seleccionado: \(type.displayName)")
    }
    
    // MARK: - Login
    func login(email: String, password: String) {
        print("🔐 AuthViewModel: Iniciando proceso de login...")
        
        // Validaciones
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, complete todos los campos"
            print("❌ AuthViewModel: Campos vacíos")
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Por favor, ingrese un email válido"
            print("❌ AuthViewModel: Email inválido")
            return
        }
        
        // Actualizar estado
        authState = .loading
        isLoading = true
        errorMessage = ""
        
        // Llamar al servicio
        authService.login(email: email, password: password, userType: selectedUserType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("❌ AuthViewModel: Error en login - \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        self.authState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] user in
                    guard let self = self else { return }
                    
                    print("🎉 AuthViewModel: Login exitoso para \(user.name)")
                    self.authState = .authenticated(user)
                    self.authService.saveUser(user)
                    self.errorMessage = ""
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Register
    func register(name: String, email: String, password: String, confirmPassword: String) {
        print("📝 AuthViewModel: Iniciando proceso de registro...")
        
        // Validaciones
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Por favor, complete todos los campos"
            print("❌ AuthViewModel: Campos vacíos en registro")
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Por favor, ingrese un email válido"
            print("❌ AuthViewModel: Email inválido en registro")
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden"
            print("❌ AuthViewModel: Contraseñas no coinciden")
            return
        }
        
        guard password.count >= 8 else {
            errorMessage = "La contraseña debe tener al menos 8 caracteres"
            print("❌ AuthViewModel: Contraseña muy corta")
            return
        }
        
        // Actualizar estado
        authState = .loading
        isLoading = true
        errorMessage = ""
        
        // Llamar al servicio
        authService.register(name: name, email: email, password: password, userType: selectedUserType)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    
                    self.isLoading = false
                    
                    if case .failure(let error) = completion {
                        print("❌ AuthViewModel: Error en registro - \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        self.authState = .error(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] user in
                    guard let self = self else { return }
                    
                    print("🎉 AuthViewModel: Registro exitoso para \(user.name)")
                    self.authState = .authenticated(user)
                    self.authService.saveUser(user)
                    self.errorMessage = ""
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Logout
    func logout() {
        print("🚪 AuthViewModel: Cerrando sesión...")
        authService.logout()
        authState = .unauthenticated
        errorMessage = ""
        print("✅ AuthViewModel: Sesión cerrada")
    }
    
    // MARK: - Helper Methods
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = ""
        if case .error = authState {
            authState = .unauthenticated
        }
    }
}

// MARK: - Extensions para mejor debugging
extension AuthViewModel {
    var authStateDescription: String {
        switch authState {
        case .idle:
            return "Idle"
        case .loading:
            return "Loading"
        case .authenticated(let user):
            return "Authenticated: \(user.name)"
        case .unauthenticated:
            return "Unauthenticated"
        case .error(let message):
            return "Error: \(message)"
        }
    }
}
