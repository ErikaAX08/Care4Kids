//
//  ChildModels.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation

// MARK: - Child Registration Request
struct ChildRegistrationRequest: Codable {
    let child_name: String
}

// MARK: - Child Registration Response
struct ChildRegistrationResponse: Codable {
    let success: Bool
    let message: String
    let child_registration: ChildRegistration
    let instructions: [String]
}

// MARK: - My Codes Response
struct MyChildCodesResponse: Codable {
    let success: Bool
    let child_codes: [ChildCode]
    let total_codes: Int
}

// MARK: - Child Code
struct ChildCode: Codable, Identifiable {
    let registration_code: String
    let child_name: String
    let status: String
    let created_at: String
    let expires_at: String
    let used_at: String?
    let is_expired: Bool
    let device_info: DeviceInfo
    
    var id: String { registration_code }
    
    var statusEnum: ChildRegistrationStatus {
        if is_expired {
            return .expired
        } else if status == "completed" {
            return .completed
        } else {
            return .pending
        }
    }
    
    var formattedCreatedDate: String {
        guard let date = parseDate(created_at) else { return created_at }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    var formattedExpiryDate: String {
        guard let date = parseDate(expires_at) else { return expires_at }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    var timeUntilExpiry: String {
        guard let expiryDate = parseDate(expires_at), !is_expired else { return "Expirado" }
        
        let timeInterval = expiryDate.timeIntervalSinceNow
        if timeInterval < 0 { return "Expirado" }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600)) / 60
        
        if hours > 0 {
            return "Expira en \(hours)h \(minutes)m"
        } else {
            return "Expira en \(minutes)m"
        }
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}

// MARK: - Child Registration
struct ChildRegistration: Codable {
    let registration_code: String
    let child_name: String
    let family_id: String
    let created_at: String
    let expires_at: String
    let status: String
    let device_info: DeviceInfo
}

// MARK: - Device Info
struct DeviceInfo: Codable {
    let device_type: String
    let device_model: String
    let notes: String
    let expected_setup_date: String
}

// MARK: - Child Registration Status
enum ChildRegistrationStatus: String, CaseIterable {
    case pending = "pending"
    case completed = "completed"
    case expired = "expired"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pendiente"
        case .completed:
            return "Completado"
        case .expired:
            return "Expirado"
        }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .completed:
            return .green
        case .expired:
            return .red
        }
    }
}

import SwiftUI

extension Color {
    static let orange = Color.orange
    static let green = Color.green
    static let red = Color.red
}
