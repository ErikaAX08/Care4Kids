//
//  LocationView.swift
//  Care4KidsiOSApp
//
//  Created by Erika Amastal on 17/08/25.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @State private var selectedChild = "Francisco I."
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176), // Coordenadas de ejemplo (Moscú)
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    // Datos simulados de los niños
    private let children = ["Francisco I.", "Erika A.", "Paul S.", "Juan C.", "Antonio F.", "Isabel N.", "Gloria S.", "Ricardo N."]
    
    // Ubicaciones de ejemplo en el mapa
    @State private var locations = [
        MapLocation(
            id: UUID(),
            name: "Francisco I.",
            coordinate: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6176),
            timestamp: Date(),
            isActive: true
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                Text("Ubicación")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Constants.Colors.darkGray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
                Text("En este panel podrás monitorear en tiempo real cada uno de tus hijos")
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // Selector de niños
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(children, id: \.self) { child in
                            ChildLocationButton(
                                name: child,
                                isSelected: selectedChild == child
                            ) {
                                selectedChild = child
                                // Aquí podrías cambiar la ubicación del mapa según el niño seleccionado
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Text("Da click en alguno de tus hijos para poder ver su ubicación")
                    .font(.system(size: 14))
                    .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)
            .background(Color.white)
            
            // Mapa
            Map(coordinateRegion: $region, annotationItems: locations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    LocationMarker(
                        name: location.name,
                        isActive: location.isActive
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cornerRadius(0)
            
            // Información de ubicación actual (opcional)
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedChild)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.darkGray)
                        
                        Text("Última ubicación: hace 2 minutos")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.darkGray.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Estado de conexión
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        
                        Text("En línea")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Botones de acción
                HStack(spacing: 16) {
                    LocationActionButton(
                        icon: "location.fill",
                        title: "Centrar",
                        color: Constants.Colors.primaryPurple
                    ) {
                        // Centrar mapa en la ubicación del niño
                    }
                    
                    LocationActionButton(
                        icon: "bell.fill",
                        title: "Notificar",
                        color: .orange
                    ) {
                        // Enviar notificación al niño
                    }
                    
                    LocationActionButton(
                        icon: "clock.fill",
                        title: "Historial",
                        color: .blue
                    ) {
                        // Ver historial de ubicaciones
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 100) // Espacio para el TabView
            }
            .background(Color.white)
        }
        .background(Constants.Colors.lightGray.opacity(0.1))
    }
}

struct ChildLocationButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : Constants.Colors.primaryPurple)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Constants.Colors.primaryPurple : Constants.Colors.primaryPurple.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LocationMarker: View {
    let name: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(isActive ? .green : .gray)
                    .frame(width: 40, height: 40)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text(name.components(separatedBy: " ").first ?? name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Constants.Colors.darkGray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                )
        }
    }
}

struct LocationActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.darkGray)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
}

// Modelo para las ubicaciones en el mapa
struct MapLocation: Identifiable {
    let id: UUID
    let name: String
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let isActive: Bool
}

#Preview {
    LocationView()
}
