import Foundation
import Combine

class AuthService: ObservableObject {
    private let apiService = APIService.shared
    private let userDefaultsKey = "saved_user"
    private let tokenKey = "auth_token"
    
    // MARK: - Login usando APIService
    func login(email: String, password: String, userType: UserType) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak self] promise in
            Task {
                do {
                    print("🔐 AuthService: Iniciando login con API...")
                    
                    // Llamar a la API
                    let response = try await self?.apiService.login(email: email, password: password)
                    
                    guard let response = response else {
                        throw AuthServiceError.unknownError
                    }
                    
                    print("✅ AuthService: Login exitoso")
                    
                    // Convertir APIUser a User local
                    let user = User(from: response.user)
                    
                    // Guardar token
                    UserDefaults.standard.set(response.token, forKey: self?.tokenKey ?? "auth_token")
                    
                    print("💾 AuthService: Token guardado")
                    
                    promise(.success(user))
                    
                } catch let apiError as APIServiceError {
                    print("❌ AuthService: Error de API - \(apiError.localizedDescription)")
                    // Detalle del error según el tipo
                    switch apiError {
                    case .badRequest(let message):
                        print("❌ Bad Request: \(message)")
                    case .unauthorized:
                        print("❌ No autorizado")
                    case .validationError(let message):
                        print("❌ Error de validación: \(message)")
                    case .serverError:
                        print("❌ Error del servidor")
                    case .networkError:
                        print("❌ Error de red")
                    case .invalidURL:
                        print("❌ URL inválida")
                    case .invalidResponse:
                        print("❌ Respuesta inválida")
                    case .unknownError:
                        print("❌ Error desconocido")
                    }
                    
                    promise(.failure(apiError))
                } catch {
                    print("💥 AuthService: Error inesperado - \(error)")
                    promise(.failure(AuthServiceError.networkError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Register usando APIService
    func register(name: String, email: String, password: String, userType: UserType) -> AnyPublisher<User, Error> {
        return Future<User, Error> { [weak   self] promise in
            Task {
                do {
                    print("📝 AuthService: Iniciando registro con API...")
                    
                    // Llamar a la API
                    let response = try await self?.apiService.register(
                        fullName: name,
                        email: email,
                        password: password,
                        passwordConfirm: password
                    )
                    
                    guard let response = response else {
                        throw AuthServiceError.unknownError
                    }
                    
                    print("✅ AuthService: Registro exitoso")
                    
                    // Convertir APIUser a User local
                    let user = User(from: response.user)
                    
                    // Guardar token
                    UserDefaults.standard.set(response.token, forKey: self?.tokenKey ?? "auth_token")
                    
                    print("💾 AuthService: Token de registro guardado")
                    
                    promise(.success(user))
                    
                } catch let apiError as APIServiceError {
                    print("❌ AuthService: Error de API en registro - \(apiError.localizedDescription)")
                    promise(.failure(apiError))
                } catch {
                    print("💥 AuthService: Error inesperado en registro - \(error)")
                    promise(.failure(AuthServiceError.networkError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Logout
    func logout() {
        Task {
            do {
                print("🚪 AuthService: Iniciando logout...")
                try await apiService.logout()
                print("✅ AuthService: Logout en servidor exitoso")
            } catch {
                print("⚠️ AuthService: Error en logout del servidor - \(error)")
                // Continúa con logout local aunque falle el servidor
            }
            
            // Limpiar datos locales
            await MainActor.run {
                UserDefaults.standard.removeObject(forKey: self.tokenKey)
                UserDefaults.standard.removeObject(forKey: "refresh_token")
                UserDefaults.standard.removeObject(forKey: self.userDefaultsKey)
                print("🧹 AuthService: Datos locales limpiados")
            }
        }
    }
    
    // MARK: - Persistencia local
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("💾 AuthService: Usuario guardado localmente")
        }
    }
    
    func getSavedUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data),
              UserDefaults.standard.string(forKey: tokenKey) != nil else {
            print("❌ AuthService: No se encontró usuario guardado o token")
            return nil
        }
        
        print("✅ AuthService: Usuario recuperado de almacenamiento local")
        return user
    }
    
    func getSavedToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func isTokenValid() -> Bool {
        // Aquí podrías implementar verificación de expiración del token
        // Por ahora solo verificamos que existe
        return getSavedToken() != nil
    }
}

enum AuthServiceError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    case invalidResponse
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Credenciales incorrectas"
        case .networkError:
            return "Error de conexión"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .unknownError:
            return "Error desconocido"
        }
    }
}
