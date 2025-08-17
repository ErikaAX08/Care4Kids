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
    @FocusState private var isTextFieldFocused: Bool
    
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
                        Text("Hola {nombre}.")
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
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if isLoading {
                                TypingIndicator()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isLoading) { _ in
                        if isLoading, let lastMessage = messages.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color.white)
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
                        
                        // Attach button
                        Button(action: {
                            // Acción para adjuntar archivos
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
                        if messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            // Activar grabación de voz
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
    }
    
    private func sendMessage() {
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Add user message
        let newMessage = ChatMessage(
            id: UUID(),
            text: userMessage,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
        isTextFieldFocused = false
        isLoading = true
        
        // Simulate AI response (aquí integrarías con Gemini API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let aiResponse = generateAIResponse(for: userMessage)
            let responseMessage = ChatMessage(
                id: UUID(),
                text: aiResponse,
                isFromUser: false,
                timestamp: Date()
            )
            
            messages.append(responseMessage)
            isLoading = false
        }
    }
    
    private func sendQuickMessage(_ message: String) {
        messageText = message
        sendMessage()
    }
    
    private func startVoiceRecording() {
        // Implementar grabación de voz
        print("Iniciando grabación de voz...")
    }
    
    private func generateAIResponse(for userMessage: String) -> String {
        // Aquí integrarías con Gemini API
        // Por ahora, respuestas simuladas
        let responses = [
            "Para proteger a tu hijo del ciberbullying, es importante establecer una comunicación abierta, configurar controles parentales y enseñarle a reconocer y reportar comportamientos inadecuados.",
            "Las aplicaciones más seguras para niños incluyen YouTube Kids, Khan Academy Kids, Scratch Jr y Duolingo. Siempre revisa las configuraciones de privacidad.",
            "Para establecer límites de tiempo de pantalla, utiliza las herramientas integradas en los dispositivos, crea horarios específicos y explica a tu hijo la importancia del equilibrio digital.",
            "Es excelente que te preocupes por la seguridad digital de tu hijo. ¿Hay algún aspecto específico sobre el que te gustaría saber más?"
        ]
        
        return responses.randomElement() ?? "Gracias por tu pregunta. Como asistente especializado en seguridad infantil digital, estoy aquí para ayudarte con cualquier duda sobre el cuidado de tus hijos en el mundo digital."
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Constants.Colors.primaryPurple)
                        )
                    
                    Text(formatTime(message.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.5))
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
                        
                        Text(message.text)
                            .font(.system(size: 16))
                            .foregroundColor(Constants.Colors.darkGray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Constants.Colors.lightGray.opacity(0.3))
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
    }
}

// Modelo para los mensajes del chat
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

#Preview {
    AssistantView()
}
