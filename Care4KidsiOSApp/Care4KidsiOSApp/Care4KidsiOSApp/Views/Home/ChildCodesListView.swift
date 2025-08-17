//
//  ChildCodesListView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct ChildCodesListView: View {
    @State private var childCodes: [ChildCode] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showAddChildView = false
    
    private let childService = ChildService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Códigos de Registro")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Constants.Colors.darkGray)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Refresh button
                    Button(action: {
                        Task { await loadChildCodes() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.primaryPurple)
                    }
                    .disabled(isLoading)
                    
                    // Add child button
                    Button(action: {
                        showAddChildView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.primaryPurple)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            
            // Content
            if isLoading && childCodes.isEmpty {
                // Loading state
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primaryPurple))
                        .scaleEffect(1.2)
                    
                    Text("Cargando códigos...")
                        .font(.system(size: 14))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                
            } else if childCodes.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(Constants.Colors.lightGray.opacity(0.3))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 32))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                    }
                    
                    VStack(spacing: 8) {
                        Text("No hay códigos generados")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.darkGray)
                        
                        Text("Agrega tu primer niño para generar un código de registro")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        showAddChildView = true
                    }) {
                        Text("Agregar Niño")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Constants.Colors.primaryPurple)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Constants.Colors.primaryPurple.opacity(0.1))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                
            } else {
                // Codes list
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(childCodes) { code in
                            ChildCodeCard(code: code)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .background(Color.white)
        .task {
            await loadChildCodes()
        }
        .refreshable {
            await loadChildCodes()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Ha ocurrido un error")
        }
        .sheet(isPresented: $showAddChildView, onDismiss: {
            // Reload codes when modal is dismissed
            Task { await loadChildCodes() }
        }) {
            AddChildView()
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func loadChildCodes() async {
        guard AuthService.isUserAuthenticated() else {
            showErrorAlert("No estás autenticado. Por favor, inicia sesión nuevamente.")
            return
        }
        
        isLoading = true
        
        do {
            print("🚀 Cargando códigos de registro...")
            
            let codes = try await childService.getMyChildCodes()
            
            childCodes = codes
            isLoading = false
            
            print("✅ Códigos cargados exitosamente: \(codes.count) códigos")
            
        } catch let error as ChildServiceError {
            isLoading = false
            showErrorAlert(error.localizedDescription)
            
            print("❌ Error cargando códigos: \(error.localizedDescription)")
            
        } catch {
            isLoading = false
            showErrorAlert("Error inesperado: \(error.localizedDescription)")
            
            print("💥 Error inesperado: \(error)")
        }
    }
    
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
}

struct ChildCodeCard: View {
    let code: ChildCode
    @State private var showCopiedAlert = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(code.child_name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.darkGray)
                        .lineLimit(1)
                    
                    Text(code.formattedCreatedDate)
                        .font(.system(size: 11))
                        .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                }
                
                Spacer()
                
                // Status badge
                HStack(spacing: 4) {
                    Circle()
                        .fill(code.statusEnum.color)
                        .frame(width: 6, height: 6)
                    
                    Text(code.statusEnum.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(code.statusEnum.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(code.statusEnum.color.opacity(0.15))
                )
            }
            
            // Code display
            Button(action: {
                UIPasteboard.general.string = code.registration_code
                showCopiedAlert = true
            }) {
                VStack(spacing: 8) {
                    Text(code.registration_code)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(Constants.Colors.primaryPurple)
                        .tracking(2)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                            .foregroundColor(Constants.Colors.primaryPurple.opacity(0.7))
                        
                        Text("Tocar para copiar")
                            .font(.system(size: 10))
                            .foregroundColor(Constants.Colors.primaryPurple.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Constants.Colors.primaryPurple.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expiry info
            VStack(spacing: 4) {
                if code.is_expired {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                        
                        Text("Expirado")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.red)
                    }
                } else {
                    Text(code.timeUntilExpiry)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.orange)
                }
                
                Text("Expira: \(code.formattedExpiryDate)")
                    .font(.system(size: 10))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .alert("¡Copiado!", isPresented: $showCopiedAlert) {
            Button("OK") { }
        } message: {
            Text("El código \(code.registration_code) ha sido copiado al portapapeles")
        }
    }
}

#Preview {
    ChildCodesListView()
}
