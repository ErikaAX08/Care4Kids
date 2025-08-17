//
//  ChildService.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation
import Combine

class ChildService: ObservableObject {
    private let apiService = APIService.shared
    
    // MARK: - Get My Child Codes
    func getMyChildCodes() async throws -> [ChildCode] {
        print("📋 ChildService: Obteniendo códigos de registro...")
        
        // Obtener el token de autenticación
        guard let token = AuthService.getCurrentToken() else {
            print("❌ ChildService: Token no encontrado")
            throw ChildServiceError.notAuthenticated
        }
        
        print("🔑 ChildService: Token obtenido: \(token.prefix(10))...")
        
        // Hacer la petición con autenticación (GET no necesita body)
        let response: MyChildCodesResponse = try await makeAuthenticatedRequest(
            endpoint: "children/my-codes/",
            method: .GET,
            body: nil,
            token: token,
            responseType: MyChildCodesResponse.self
        )
        
        print("✅ ChildService: Códigos obtenidos exitosamente")
        print("📊 Total de códigos: \(response.total_codes)")
        for code in response.child_codes {
            print("🔢 Código: \(code.registration_code) - Niño: \(code.child_name) - Estado: \(code.status)")
        }
        
        return response.child_codes
    }
    func generateRegistrationCode(childName: String) async throws -> ChildRegistration {
        print("👶 ChildService: Generando código de registro para '\(childName)'...")
        
        // Obtener el token de autenticación
        guard let token = AuthService.getCurrentToken() else {
            print("❌ ChildService: Token no encontrado")
            throw ChildServiceError.notAuthenticated
        }
        
        print("🔑 ChildService: Token obtenido: \(token.prefix(10))...")
        
        // Crear el request
        let childRequest = ChildRegistrationRequest(child_name: childName)
        let requestBody = try JSONEncoder().encode(childRequest)
        
        // Hacer la petición con autenticación
        let response: ChildRegistrationResponse = try await makeAuthenticatedRequest(
            endpoint: "children/generate-code/",
            method: .POST,
            body: requestBody,
            token: token,
            responseType: ChildRegistrationResponse.self
        )
        
        print("✅ ChildService: Código de registro generado exitosamente")
        print("🔢 Código: \(response.child_registration.registration_code)")
        print("👶 Niño: \(response.child_registration.child_name)")
        print("⏰ Expira: \(response.child_registration.expires_at)")
        
        return response.child_registration
    }
    
    // MARK: - Private Methods
    private func makeAuthenticatedRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod,
        body: Data? = nil,
        token: String,
        responseType: T.Type
    ) async throws -> T {
        
        print("🚀 === INICIO DE REQUEST AUTENTICADO (CHILD SERVICE) ===")
        print("🎯 Endpoint: \(endpoint)")
        print("🔧 Method: \(method.rawValue)")
        print("🔑 Token: \(token.prefix(10))...")
        
        let baseURL = "http://127.0.0.1:8000/api/"
        
        guard let url = URL(string: baseURL + endpoint) else {
            print("❌ URL INVÁLIDA: '\(baseURL + endpoint)'")
            throw ChildServiceError.invalidRequest
        }
        
        print("🌐 URL final: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
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
                throw ChildServiceError.invalidResponse
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
                    throw ChildServiceError.invalidResponse
                }
                
            case 401:
                print("❌ Unauthorized (401) - Token inválido o expirado")
                throw ChildServiceError.notAuthenticated
            case 400:
                print("❌ Bad Request (400)")
                throw ChildServiceError.invalidRequest
            case 500:
                print("❌ Server Error (500)")
                throw ChildServiceError.serverError
            default:
                print("❌ Status code no manejado: \(httpResponse.statusCode)")
                throw ChildServiceError.unknownError
            }
            
        } catch let error as ChildServiceError {
            print("❌ Re-throwing ChildServiceError: \(error)")
            throw error
        } catch {
            print("❌ ERROR DE RED/URLSession:")
            print("❌ Error: \(error)")
            print("❌ Type: \(type(of: error))")
            print("❌ LocalizedDescription: \(error.localizedDescription)")
            throw ChildServiceError.networkError
        }
    }
}

// MARK: - Child Service Errors
enum ChildServiceError: Error, LocalizedError {
    case notAuthenticated
    case invalidRequest
    case networkError
    case serverError
    case invalidResponse
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "No estás autenticado. Por favor, inicia sesión nuevamente."
        case .invalidRequest:
            return "Los datos proporcionados no son válidos."
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
