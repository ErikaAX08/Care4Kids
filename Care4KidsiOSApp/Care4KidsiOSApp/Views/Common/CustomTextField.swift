//
//  CustomTextField.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType
    @State private var isSecureVisible = false
    
    init(title: String, placeholder: String, text: Binding<String>, isSecure: Bool = false, keyboardType: UIKeyboardType = .default) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Constants.Fonts.body)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.darkGray)
            
            HStack {
                if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(keyboardType)
                }
                
                if isSecure {
                    Button(action: {
                        isSecureVisible.toggle()
                    }) {
                        Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                            .foregroundColor(Constants.Colors.darkGray)
                    }
                    .padding(.trailing, 12)
                }
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(Constants.Colors.lightGray)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}
