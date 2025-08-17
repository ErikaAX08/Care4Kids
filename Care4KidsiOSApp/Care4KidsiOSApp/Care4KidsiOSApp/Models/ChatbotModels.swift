//
//  ChatbotModels.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation

// MARK: - Chatbot Request Models
struct ChatbotRequest: Codable {
    let message: String
}

// MARK: - Chatbot Response Models
struct ChatbotResponse: Codable {
    let success: Bool
    let response: String
    let user_message: String
    let timestamp: String
}

// MARK: - Chat Message Model (actualizado)
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    let status: MessageStatus
    
    init(id: UUID = UUID(), text: String, isFromUser: Bool, timestamp: Date = Date(), status: MessageStatus = .sent) {
        self.id = id
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.status = status
    }
}

// MARK: - Message Status
enum MessageStatus: String, Codable {
    case sending
    case sent
    case failed
    case received
}
