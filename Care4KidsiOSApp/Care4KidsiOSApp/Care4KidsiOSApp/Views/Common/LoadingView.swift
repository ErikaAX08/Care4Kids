//
//  LoadingView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    
    init(message: String = "Cargando...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primaryPurple))
                .scaleEffect(1.5)
            
            Text(message)
                .font(Constants.Fonts.body)
                .foregroundColor(Constants.Colors.darkGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.opacity(0.9))
    }
}
