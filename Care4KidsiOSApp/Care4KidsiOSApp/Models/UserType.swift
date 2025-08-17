//
//  UserType.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation

enum UserType: String, CaseIterable, Codable {
    case parent = "parent"
    case child = "child"
    
    var displayName: String {
        switch self {
        case .parent:
            return "Del tutor"
        case .child:
            return "Del hijo"
        }
    }
}
