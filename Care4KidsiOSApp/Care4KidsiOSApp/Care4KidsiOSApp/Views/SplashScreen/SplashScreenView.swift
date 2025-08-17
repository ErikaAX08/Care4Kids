//
//  SplashScreenView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var animationAmount: CGFloat = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [
                        Constants.Colors.primaryPurple,
                        Constants.Colors.secondaryPink
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo animado
                    VStack(spacing: 16) {
                        // Logo de Care4Kids
                        LogoView()
                            .scaleEffect(0.8 + animationAmount * 0.2)
                            .animation(
                                Animation.easeInOut(duration: 2.0)
                                    .repeatForever(autoreverses: true),
                                value: animationAmount
                            )
                        
                        // Título
                        VStack(spacing: 8) {
                            Text("Care")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            + Text("4")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(Constants.Colors.secondaryPink)
                            + Text("Kids")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Protección digital familiar")
                                .font(Constants.Fonts.subtitle)
                                .foregroundColor(.white.opacity(0.9))
                                .opacity(textOpacity)
                                .animation(.easeIn(duration: 1.0).delay(1.0), value: textOpacity)
                        }
                    }
                    
                    Spacer()
                    
                    // Indicador de carga
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("Cargando...")
                            .font(Constants.Fonts.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 50)
                }
                .padding(32)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationAmount = 1.0
                textOpacity = 1.0
            }
        }
    }
}

struct LogoView: View {
    var body: some View {
        ZStack {
            // Círculo de fondo
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 120, height: 120)
            
            Circle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 100, height: 100)
            
            // Icono central
            VStack(spacing: 4) {
                // Figura de familia estilizada
                HStack(spacing: 8) {
                    // Adulto
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white)
                        .frame(width: 16, height: 24)
                    
                    // Niño
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 12, height: 18)
                }
                
                // Escudo protector
                Image(systemName: "shield.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.white)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
