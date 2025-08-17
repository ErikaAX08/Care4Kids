//
//  AssistantView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct AssistantView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Services
    private let chatbotService = ChatbotService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                Text("Asistente")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Constants.Colors.darkGray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                Text("En este panel podrás preguntarle casi cualquier cosa a un chatbot, por ejemplo, ¿Cuáles son los sitios que mi hijo debe evitar visitar?, ¿Qué debo hacer si mi hijo sufre de ciberbullying?, entre otras dudas...")
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(2)
            }
            .padding(.bottom, 20)
            .background(Color.white)
            
            // Chat Area
            if messages.isEmpty {
                // Welcome screen
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Animated gradient text
                    VStack(spacing: 16) {
                        Text("Hola.")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("¿En qué puedo ayudarte?")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .multilineTextAlignment(.center)
                    
                    // Quick action buttons
                    VStack(spacing: 12) {
                        QuickActionButton(
                            text: "¿Cómo proteger a mi hijo del ciberbullying?",
                            action: { sendQuickMessage("¿Cómo proteger a mi hijo del ciberbullying?") }
                        )
                        
                        QuickActionButton(
                            text: "¿Qué aplicaciones son seguras para niños?",
                            action: { sendQuickMessage("¿Qué aplicaciones son seguras para niños?") }
                        )
                        
                        QuickActionButton(
                            text: "¿Cómo establecer límites de tiempo de pantalla?",
                            action: { sendQuickMessage("¿Cómo establecer límites de tiempo de pantalla?") }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .background(Color.white)
            } else {
                // Chat messages
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                        
                        if isLoading {
                            TypingIndicator()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .background(Color.white)
                .onChange(of: messages.count) { _ in
                    scrollToLastMessage()
                }
                .onChange(of: isLoading) { _ in
                    if isLoading {
                        scrollToLastMessage()
                    }
                }
            }
            
            // Input area
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 12) {
                    // Text input
                    HStack {
                        TextField("Pregunta lo que quieras", text: $messageText, axis: .vertical)
                            .focused($isTextFieldFocused)
                            .lineLimit(1...4)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .onSubmit {
                                if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    sendMessage()
                                }
                            }
                        
                        // Attach button
                        Button(action: {
                            // Acción para adjuntar archivos (futuro)
                            print("📎 Adjuntar archivos - Funcionalidad pendiente")
                        }) {
                            Image(systemName: "paperclip")
                                .font(.system(size: 20))
                                .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                        }
                        .padding(.trailing, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Constants.Colors.lightGray.opacity(0.3))
                    )
                    
                    // Voice/Send button
                    Button(action: {
                        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedMessage.isEmpty {
                            // Activar grabación de voz (futuro)
                            startVoiceRecording()
                        } else {
                            // Enviar mensaje
                            sendMessage()
                        }
                    }) {
                        Image(systemName: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "mic.fill" : "arrow.up")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                          Constants.Colors.darkGray.opacity(0.6) :
                                          Constants.Colors.primaryPurple)
                            )
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
            }
        }
        .background(Constants.Colors.lightGray.opacity(0.05))
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Ha ocurrido un error")
        }
    }
    
    // MARK: - Private Methods
    
    private func sendMessage() {
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Verificar autenticación
        guard AuthService.isUserAuthenticated() else {
            showErrorAlert("No estás autenticado. Por favor, inicia sesión nuevamente.")
            return
        }
        
        // Add user message
        let newMessage = ChatMessage(
            text: userMessage,
            isFromUser: true,
            status: .sent
        )
        
        messages.append(newMessage)
        messageText = ""
        isTextFieldFocused = false
        isLoading = true
        
        // Send to API
        Task {
            do {
                print("🚀 Enviando mensaje al chatbot: '\(userMessage)'")
                
                let response = try await chatbotService.sendMessage(userMessage)
                
                await MainActor.run {
                    let aiMessage = ChatMessage(
                        text: response,
                        isFromUser: false,
                        status: .received
                    )
                    
                    messages.append(aiMessage)
                    isLoading = false
                    
                    print("✅ Respuesta del chatbot recibida y mostrada")
                }
                
            } catch let error as ChatbotServiceError {
                await MainActor.run {
                    isLoading = false
                    
                    // Si es error de autenticación, mostrar mensaje específico
                    if case .notAuthenticated = error {
                        showErrorAlert("Tu sesión ha expirado. Por favor, inicia sesión nuevamente.")
                    } else {
                        showErrorAlert(error.localizedDescription)
                    }
                    
                    // Agregar mensaje de error en el chat
                    let errorMessage = ChatMessage(
                        text: "❌ Error: \(error.localizedDescription)",
                        isFromUser: false,
                        status: .failed
                    )
                    messages.append(errorMessage)
                }
                
                print("❌ Error enviando mensaje: \(error.localizedDescription)")
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    showErrorAlert("Error inesperado: \(error.localizedDescription)")
                    
                    let errorMessage = ChatMessage(
                        text: "❌ Error inesperado. Por favor, intenta nuevamente.",
                        isFromUser: false,
                        status: .failed
                    )
                    messages.append(errorMessage)
                }
                
                print("💥 Error inesperado: \(error)")
            }
        }
    }
    
    private func sendQuickMessage(_ message: String) {
        messageText = message
        sendMessage()
    }
    
    private func startVoiceRecording() {
        // Implementar grabación de voz en el futuro
        print("🎤 Iniciando grabación de voz...")
        showErrorAlert("Funcionalidad de voz próximamente disponible")
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func scrollToLastMessage() {
        // Usar un pequeño delay para asegurar que el contenido se haya renderizado
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // El scroll automático se maneja por el ScrollView naturalmente
            // al agregar nuevos elementos al final
        }
    }
}

// MARK: - Supporting Views

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(alignment: .bottom, spacing: 8) {
                        if message.status == .failed {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                        
                        Text(message.text)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(message.status == .failed ? Color.red.opacity(0.8) : Constants.Colors.primaryPurple)
                            )
                    }
                    
                    HStack(spacing: 4) {
                        Text(formatTime(message.timestamp))
                            .font(.system(size: 12))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
                        
                        // Status indicator for user messages
                        switch message.status {
                        case .sending:
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
                        case .sent:
                            Image(systemName: "checkmark")
                                .font(.system(size: 10))
                                .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
                        case .failed:
                            Image(systemName: "xmark")
                                .font(.system(size: 10))
                                .foregroundColor(.red)
                        case .received:
                            EmptyView()
                        }
                    }
                    .padding(.trailing, 8)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 8) {
                        // AI Avatar
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: message.status == .failed ? [.red, .orange] : [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: message.status == .failed ? "exclamationmark.triangle.fill" : "brain.head.profile")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Text(message.text)
                            .font(.system(size: 16))
                            .foregroundColor(Constants.Colors.darkGray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(message.status == .failed ? Color.red.opacity(0.1) : Constants.Colors.lightGray.opacity(0.3))
                            )
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
                        .padding(.leading, 40)
                }
                
                Spacer(minLength: 60)
            }
        }
        .id(message.id)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct QuickActionButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.darkGray)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Constants.Colors.lightGray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Constants.Colors.lightGray, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 8) {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Constants.Colors.darkGray.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .offset(y: animationOffset)
                            .animation(
                                Animation
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: animationOffset
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Constants.Colors.lightGray.opacity(0.3))
                )
            }
            
            Spacer(minLength: 60)
        }
        .onAppear {
            animationOffset = -4
        }
        .id("typing")
    }
}

#Preview {
    AssistantView()
}
