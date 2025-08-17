//
//  ErrorView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondaryPink)
            
            Text(message)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.darkGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let onRetry = onRetry {
                CustomButton(title: "Reintentar", style: .primary) {
                    onRetry()
                }
                .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}
