//
//  ChatbotService.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation
import Combine

class ChatbotService: ObservableObject {
    private let apiService = APIService.shared
    
    // MARK: - Send Message to Chatbot
    func sendMessage(_ message: String) async throws -> String {
        print("🤖 ChatbotService: Enviando mensaje al chatbot...")
        print("📝 Mensaje: '\(message)'")
        
        // Obtener el token de autenticación
        guard let token = AuthService().getSavedToken() else {
            print("❌ ChatbotService: Token no encontrado")
            throw ChatbotServiceError.notAuthenticated
        }
        
        print("🔑 ChatbotService: Token obtenido: \(token.prefix(10))...")
        
        // Crear el request
        let chatbotRequest = ChatbotRequest(message: message)
        let requestBody = try JSONEncoder().encode(chatbotRequest)
        
        // Hacer la petición con autenticación
        let response: ChatbotResponse = try await makeAuthenticatedRequest(
            endpoint: "chatbot/",
            method: .POST,
            body: requestBody,
            token: token,
            responseType: ChatbotResponse.self
        )
        
        print("✅ ChatbotService: Respuesta recibida del chatbot")
        print("🤖 Respuesta: '\(response.response)'")
        
        return response.response
    }
    
    // MARK: - Private Methods
    private func makeAuthenticatedRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        token: String,
        responseType: T.Type
    ) async throws -> T {
        
        print("🚀 === INICIO DE REQUEST AUTENTICADO ===")
        print("🎯 Endpoint: \(endpoint)")
        print("🔧 Method: \(method.rawValue)")
        print("🔑 Token: \(token.prefix(10))...")
        
        let baseURL = "http://127.0.0.1:8000/api/"
        
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ URL INVÁLIDA: '\(baseURL + endpoint)'")
            throw APIServiceError.invalidURL
        }
        
        print("🌐 URL final: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Agregar el token de autorización
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
            if let bodyString = String(data: body, encoding: .utf8) {
                print("📦 Request body: \(bodyString)")
            }
        }
        
        print("📋 Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("⏳ Enviando request autenticado...")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("📨 Response recibido!")
            print("📊 Data size: \(data.count) bytes")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ FALLO: Response no es HTTPURLResponse")
                throw APIServiceError.invalidResponse
            }
            
            print("📡 Status code: \(httpResponse.statusCode)")
            
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
                    throw ChatbotServiceError.invalidResponse
                }
                
            case 401:
                print("❌ Unauthorized (401) - Token inválido o expirado")
                throw ChatbotServiceError.notAuthenticated
            case 400:
                print("❌ Bad Request (400)")
                throw ChatbotServiceError.invalidMessage
            case 500:
                print("❌ Server Error (500)")
                throw ChatbotServiceError.serverError
            default:
                print("❌ Status code no manejado: \(httpResponse.statusCode)")
                throw ChatbotServiceError.unknownError
            }
            
        } catch let error as ChatbotServiceError {
            print("❌ Re-throwing ChatbotServiceError: \(error)")
            throw error
        } catch let error as APIServiceError {
            print("❌ APIServiceError: \(error)")
            throw ChatbotServiceError.networkError
        } catch {
            print("❌ ERROR DE RED/URLSession:")
            print("❌ Error: \(error)")
            print("❌ Type: \(type(of: error))")
            print("❌ LocalizedDescription: \(error.localizedDescription)")
            throw ChatbotServiceError.networkError
        }
    }
}

// MARK: - Chatbot Service Errors
enum ChatbotServiceError: Error, LocalizedError {
    case notAuthenticated
    case invalidMessage
    case networkError
    case serverError
    case invalidResponse
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "No estás autenticado. Por favor, inicia sesión nuevamente."
        case .invalidMessage:
            return "El mensaje no es válido."
        case .networkError:
            return "Error de conexión. Verifica tu internet."
        case .serverError:
            return "Error del servidor. Intenta más tarde."
        case .invalidResponse:
            return "Respuesta inválida del servidor."
        case .unknownError:
            return "Error desconocido."
        }
    }
}
