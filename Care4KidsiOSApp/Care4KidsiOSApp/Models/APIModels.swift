import Foundation

// MARK: - API Request Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let full_name: String
    let email: String
    let password: String
    let password_confirm: String
}

// MARK: - API Response Models
struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let user: APIUser
    let token: String
}

struct APIUser: Codable {
    let id: Int
    let username: String
    let email: String
    let full_name: String
    let family_id: String
    let role: String
    let is_verified: Bool
}

struct APIError: Codable {
    let message: String
    let errors: [String: [String]]?
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - API Errors
enum APIServiceError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError
    case unauthorized
    case badRequest(String)
    case validationError(String)
    case serverError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .networkError:
            return "Error de conexión. Verifica tu internet"
        case .unauthorized:
            return "Credenciales incorrectas"
        case .badRequest(let message):
            return message
        case .validationError(let message):
            return message
        case .serverError:
            return "Error del servidor. Intenta más tarde"
        case .unknownError:
            return "Error desconocido"
        }
    }
}

// MARK: - User Extensions
extension User {
    init(from apiUser: APIUser) {
        self.init(
            id: String(apiUser.id),           // Convertir Int a String
            email: apiUser.email,
            name: apiUser.full_name,
            userType: UserType(rawValue: apiUser.role) ?? .parent  // Usar "role"
        )
    }
}
