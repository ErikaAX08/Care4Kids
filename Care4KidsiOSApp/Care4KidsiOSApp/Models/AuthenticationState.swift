//
//  AuthenticationState.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import Foundation

enum AuthenticationState: Equatable {
    case idle
    case loading
    case authenticated(User)
    case unauthenticated
    case error(String)
    
    static func == (lhs: AuthenticationState, rhs: AuthenticationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.unauthenticated, .unauthenticated):
            return true
        case let (.authenticated(lhsUser), .authenticated(rhsUser)):
            return lhsUser.id == rhsUser.id
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
