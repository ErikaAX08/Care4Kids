//
//  CustomButton.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let style: ButtonStyle
    
    init(title: String, isLoading: Bool = false, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.style = style
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .foregroundColor(style.textColor)
                } else {
                    Text(title)
                        .font(Constants.Fonts.subtitle)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(isLoading ? style.backgroundColor.opacity(0.7) : style.backgroundColor)
            .foregroundColor(style.textColor)
            .cornerRadius(12)
            .shadow(color: style.backgroundColor.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case outline
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Constants.Colors.primaryPurple
            case .secondary:
                return Constants.Colors.lightGray
            case .outline:
                return Color.clear
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary:
                return .white
            case .secondary:
                return Constants.Colors.primaryPurple
            case .outline:
                return Constants.Colors.primaryPurple
            }
        }
    }
}
