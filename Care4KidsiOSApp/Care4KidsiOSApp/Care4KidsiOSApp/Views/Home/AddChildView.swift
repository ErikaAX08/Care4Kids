//
//  AddChildView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var childName = ""
    @State private var registrationCode: String?
    @State private var childRegistration: ChildRegistration?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var step: AddChildStep = .nameInput
    
    private let childService = ChildService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    Text("Agregar Niño")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Constants.Colors.darkGray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    // Steps indicator
                    HStack(spacing: 12) {
                        StepIndicator(
                            number: 1,
                            title: "Nombre",
                            isActive: step == .nameInput,
                            isCompleted: step == .codeGenerated
                        )
                        
                        Rectangle()
                            .fill(step == .codeGenerated ? Constants.Colors.primaryPurple : Constants.Colors.lightGray)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                        
                        StepIndicator(
                            number: 2,
                            title: "Código",
                            isActive: step == .codeGenerated,
                            isCompleted: false
                        )
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 30)
                .background(Color.white)
                
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        if step == .nameInput {
                            NameInputStep(
                                childName: $childName,
                                isLoading: isLoading,
                                onGenerate: generateCode
                            )
                        } else {
                            CodeGeneratedStep(
                                childRegistration: childRegistration,
                                onDone: {
                                    dismiss()
                                },
                                onAddAnother: {
                                    // Reset to add another child
                                    step = .nameInput
                                    childName = ""
                                    registrationCode = nil
                                    childRegistration = nil
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .background(Constants.Colors.lightGray.opacity(0.05))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primaryPurple)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Ha ocurrido un error")
        }
    }
    
    // MARK: - Private Methods
    
    private func generateCode() {
        let trimmedName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showErrorAlert("Por favor, ingresa el nombre del niño")
            return
        }
        
        guard AuthService.isUserAuthenticated() else {
            showErrorAlert("No estás autenticado. Por favor, inicia sesión nuevamente.")
            return
        }
        
        isLoading = true
        
        Task {
            do {
                print("🚀 Generando código para: '\(trimmedName)'")
                
                let registration = try await childService.generateRegistrationCode(childName: trimmedName)
                
                await MainActor.run {
                    childRegistration = registration
                    registrationCode = registration.registration_code
                    step = .codeGenerated
                    isLoading = false
                    
                    print("✅ Código generado exitosamente: \(registration.registration_code)")
                }
                
            } catch let error as ChildServiceError {
                await MainActor.run {
                    isLoading = false
                    showErrorAlert(error.localizedDescription)
                }
                
                print("❌ Error generando código: \(error.localizedDescription)")
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorAlert("Error inesperado: \(error.localizedDescription)")
                }
                
                print("💥 Error inesperado: \(error)")
            }
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Add Child Steps

enum AddChildStep {
    case nameInput
    case codeGenerated
}

// MARK: - Supporting Views

struct StepIndicator: View {
    let number: Int
    let title: String
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(textColor)
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isActive || isCompleted ? Constants.Colors.primaryPurple : Constants.Colors.darkGray.opacity(0.6))
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return Constants.Colors.primaryPurple
        } else if isActive {
            return Constants.Colors.primaryPurple.opacity(0.2)
        } else {
            return Constants.Colors.lightGray
        }
    }
    
    private var textColor: Color {
        if isActive {
            return Constants.Colors.primaryPurple
        } else {
            return Constants.Colors.darkGray.opacity(0.6)
        }
    }
}

struct NameInputStep: View {
    @Binding var childName: String
    let isLoading: Bool
    let onGenerate: () -> Void
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Illustration
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Constants.Colors.primaryPurple.opacity(0.2), Constants.Colors.secondaryPink.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Constants.Colors.primaryPurple, Constants.Colors.secondaryPink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 12) {
                    Text("¿Cómo se llama tu hijo/a?")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Constants.Colors.darkGray)
                        .multilineTextAlignment(.center)
                    
                    Text("Ingresa el nombre para generar un código de registro que podrás usar en el dispositivo del niño.")
                        .font(.system(size: 16))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
            }
            
            // Name input
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nombre del niño")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Constants.Colors.darkGray)
                    
                    TextField("Ej: María, Juan, Ana...", text: $childName)
                        .focused($isNameFieldFocused)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            isNameFieldFocused ? Constants.Colors.primaryPurple : Constants.Colors.lightGray,
                                            lineWidth: 2
                                        )
                                )
                        )
                        .onSubmit {
                            if !childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onGenerate()
                            }
                        }
                }
                
                // Generate button
                Button(action: onGenerate) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isLoading ? "Generando código..." : "Generar código")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading ?
                                Constants.Colors.darkGray.opacity(0.3) :
                                Constants.Colors.primaryPurple
                            )
                    )
                }
                .disabled(childName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            
            Spacer()
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }
}

struct CodeGeneratedStep: View {
    let childRegistration: ChildRegistration?
    let onDone: () -> Void
    let onAddAnother: () -> Void
    @State private var showCopiedAlert = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Success illustration
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.2), Color.mint.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 12) {
                    Text("¡Código generado!")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Constants.Colors.darkGray)
                    
                    if let registration = childRegistration {
                        Text("Código de registro para \(registration.child_name)")
                            .font(.system(size: 16))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // Code display
            if let registration = childRegistration {
                VStack(spacing: 20) {
                    // Code box
                    VStack(spacing: 16) {
                        Text("Código de registro")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                        
                        Button(action: {
                            UIPasteboard.general.string = registration.registration_code
                            showCopiedAlert = true
                        }) {
                            HStack(spacing: 12) {
                                Text(registration.registration_code)
                                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                                    .foregroundColor(Constants.Colors.primaryPurple)
                                    .tracking(4)
                                
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(Constants.Colors.primaryPurple.opacity(0.7))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Constants.Colors.primaryPurple.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Constants.Colors.primaryPurple.opacity(0.3), lineWidth: 2)
                                            .shadow(color: Constants.Colors.primaryPurple.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("Toca para copiar")
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
                    }
                    
                    // Instructions
                    VStack(spacing: 16) {
                        Text("Instrucciones")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Constants.Colors.darkGray)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionRow(
                                number: 1,
                                text: "En el dispositivo del niño, descarga la app Care4Kids"
                            )
                            
                            InstructionRow(
                                number: 2,
                                text: "Selecciona 'Soy un niño' y usa este código de 6 dígitos"
                            )
                            
                            InstructionRow(
                                number: 3,
                                text: "El código expira en 24 horas"
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Constants.Colors.lightGray.opacity(0.3))
                    )
                    
                    // Expiry info
                    if let expiryDate = parseExpiryDate(registration.expires_at) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            
                            Text("Expira: \(formatExpiryDate(expiryDate))")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                }
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: onDone) {
                    Text("Listo")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Constants.Colors.primaryPurple)
                        )
                }
                
                Button(action: onAddAnother) {
                    Text("Agregar otro niño")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Constants.Colors.primaryPurple.opacity(0.1))
                        )
                }
            }
            
            Spacer()
        }
        .alert("¡Copiado!", isPresented: $showCopiedAlert) {
            Button("OK") { }
        } message: {
            Text("El código ha sido copiado al portapapeles")
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseExpiryDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
    
    private func formatExpiryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.primaryPurple)
                    .frame(width: 24, height: 24)
                
                Text("\(number)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.darkGray)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}

#Preview {
    AddChildView()
}
