//
//  Constants.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct Constants {
    struct Colors {
        static let primaryPurple = Color(red: 0.39, green: 0.4, blue: 0.95) // #6366F1
        static let secondaryPink = Color(red: 0.93, green: 0.29, blue: 0.6) // #EC4899
        static let lightGray = Color(red: 0.96, green: 0.97, blue: 0.98)
        static let darkGray = Color(red: 0.37, green: 0.38, blue: 0.4)
    }
    
    struct Fonts {
        static let title = Font.system(size: 24, weight: .bold)
        static let subtitle = Font.system(size: 18, weight: .medium)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
    }
    
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    // MARK: - API Configuration
   struct API {
       static let baseURL = "http://localhost:8000/api/"
       static let timeout: TimeInterval = 30.0
       
       struct Endpoints {
           static let login = "auth/login/"
           static let register = "auth/register/"
           static let logout = "auth/logout/"
           static let profile = "auth/profile/"
       }
   }
}
