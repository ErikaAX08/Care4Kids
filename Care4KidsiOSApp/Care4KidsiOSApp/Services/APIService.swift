//
//  APIService.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation
import Combine

class APIService: ObservableObject {
    static let shared = APIService()
    private let baseURL = "http://127.0.0.1:8000/api/"
    
    private init() {}
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        
        print("🚀 === INICIO DE REQUEST ===")
        print("🎯 Endpoint: \(endpoint)")
        print("🔧 Method: \(method.rawValue)")
        print("🏠 Base URL: \(baseURL)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ URL INVÁLIDA: '\(baseURL + endpoint)'")
            throw APIServiceError.invalidURL
        }
        
        print("🌐 URL final: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
            if let bodyString = String(data: body, encoding: .utf8) {
                print("📦 Request body: \(bodyString)")
            }
        }
        
        print("⏳ Enviando request...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("📨 Response recibido!")
            print("📊 Data size: \(data.count) bytes")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ FALLO: Response no es HTTPURLResponse")
                print("❌ Response type: \(type(of: response))")
                throw APIServiceError.invalidResponse
            }
            
            print("📡 Status code: \(httpResponse.statusCode)")
            print("📋 Headers: \(httpResponse.allHeaderFields)")
            
            // SIEMPRE mostrar la respuesta raw
            let responseString = String(data: data, encoding: .utf8) ?? "No se pudo decodificar"
            print("📄 Response body RAW: '\(responseString)'")
            
            switch httpResponse.statusCode {
            case 200...299:
                print("✅ Status code exitoso, intentando decodificar...")
                print("🎯 Tipo esperado: \(responseType)")
                
                do {
                    let decoder = JSONDecoder()
                    let decodedResponse = try decoder.decode(responseType, from: data)
                    print("✅ JSON decodificado exitosamente!")
                    print("🏁 === FIN REQUEST EXITOSO ===")
                    return decodedResponse
                } catch {
                    print("❌ ERROR DECODIFICANDO JSON:")
                    print("❌ Error: \(error)")
                    
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("❌ Key no encontrada: '\(key.stringValue)'")
                            print("❌ Context: \(context)")
                        case .typeMismatch(let type, let context):
                            print("❌ Tipo incorrecto: esperaba \(type)")
                            print("❌ Context: \(context)")
                        case .valueNotFound(let type, let context):
                            print("❌ Valor no encontrado para tipo: \(type)")
                            print("❌ Context: \(context)")
                        case .dataCorrupted(let context):
                            print("❌ Datos corruptos: \(context)")
                        @unknown default:
                            print("❌ Error de decodificación desconocido")
                        }
                    }
                    print("🏁 === FIN REQUEST CON ERROR DE DECODIFICACIÓN ===")
                    throw APIServiceError.unknownError
                }
                
            case 400:
                print("❌ Bad Request (400)")
                throw APIServiceError.badRequest("Bad request")
            case 401:
                print("❌ Unauthorized (401)")
                throw APIServiceError.unauthorized
            case 404:
                print("❌ Not Found (404)")
                throw APIServiceError.unknownError
            case 500:
                print("❌ Server Error (500)")
                throw APIServiceError.serverError
            default:
                print("❌ Status code no manejado: \(httpResponse.statusCode)")
                throw APIServiceError.unknownError
            }
            
        } catch let error as APIServiceError {
            print("❌ Re-throwing APIServiceError: \(error)")
            print("🏁 === FIN REQUEST CON API ERROR ===")
            throw error
        } catch {
            print("❌ ERROR DE RED/URLSession:")
            print("❌ Error: \(error)")
            print("❌ Type: \(type(of: error))")
            print("❌ LocalizedDescription: \(error.localizedDescription)")
            print("🏁 === FIN REQUEST CON ERROR DE RED ===")
            throw APIServiceError.networkError
        }
    }
    
    // MARK: - Authentication Methods
    func login(email: String, password: String) async throws -> AuthResponse {
        let loginData = LoginRequest(email: email, password: password)
        let requestBody = try JSONEncoder().encode(loginData)
        
        return try await makeRequest(
            endpoint: "auth/login/",
            method: .POST,
            body: requestBody,
            responseType: AuthResponse.self
        )
    }
    
    func register(fullName: String, email: String, password: String, passwordConfirm: String) async throws -> AuthResponse {
        let registerData = RegisterRequest(
            full_name: fullName,
            email: email,
            password: password,
            password_confirm: passwordConfirm
        )
        let requestBody = try JSONEncoder().encode(registerData)
        
        return try await makeRequest(
            endpoint: "auth/register/",
            method: .POST,
            body: requestBody,
            responseType: AuthResponse.self
        )
    }
    
    func logout() async throws {
        // Si tu API tiene endpoint de logout
        // try await makeRequest(endpoint: "auth/logout/", method: .POST, responseType: EmptyResponse.self)
        
        // Limpiar datos locales
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "user_data")
    }
}
