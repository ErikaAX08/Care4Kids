import SwiftUI
import CoreLocation
import SafariServices
import UIKit
import UserNotifications

// MARK: - ContentView CORREGIDO
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var appBlockingManager = AppBlockingManager()
    @StateObject private var parentalControlManager = ParentalControlManager()
    @State private var selectedTab = 0
    @State private var showingParentalControl = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Botón de Control Parental prominente
            parentalControlHeader
            
            TabView(selection: $selectedTab) {
                AppListView()
                    .tabItem {
                        Image(systemName: "apps.iphone")
                        Text("Apps")
                    }
                    .tag(0)
                
                AppBlockingView()
                    .tabItem {
                        Image(systemName: "lock.shield")
                        Text("Bloqueos")
                    }
                    .tag(1)
                
                WebControlView()
                    .tabItem {
                        Image(systemName: "shield.fill")
                        Text("Web Control")
                    }
                    .tag(2)
                
                LocationView(locationManager: locationManager)
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text("Ubicación")
                    }
                    .tag(3)
                
                UsageLimitView()
                    .tabItem {
                        Image(systemName: "hourglass")
                        Text("Límites")
                    }
                    .tag(4)
            }
            .accentColor(.blue)
        }
        .environmentObject(appBlockingManager)
        .environmentObject(parentalControlManager)
        .sheet(isPresented: $showingParentalControl) {
            // ✅ SOLUCIÓN: Pasar explícitamente los EnvironmentObjects
            ParentalControlSetupView()
                .environmentObject(parentalControlManager)
                .environmentObject(appBlockingManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            appBlockingManager.checkForBlockedAppUsage()
        }
    }
    
    private var parentalControlHeader: some View {
        VStack(spacing: 10) {
            if parentalControlManager.isParentalControlEnabled {
                HStack {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Control Parental Activo")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("Protección para \(parentalControlManager.childAge.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Configurar") {
                        showingParentalControl = true
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.green.opacity(0.3)),
                    alignment: .bottom
                )
            } else {
                HStack {
                    Image(systemName: "shield.slash")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Control Parental Inactivo")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("Activa la protección para tu hijo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Activar Ahora") {
                        showingParentalControl = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.orange.opacity(0.3)),
                    alignment: .bottom
                )
            }
        }
    }
}

// MARK: - VISTA DE CONFIGURACIÓN CORREGIDA
struct ParentalControlSetupView: View {
    @EnvironmentObject var parentalControlManager: ParentalControlManager
    @EnvironmentObject var appBlockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss
    @State private var pinInput = ""
    @State private var confirmPin = ""
    @State private var showingPinError = false
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var currentStep: SetupStep = .welcome
    @State private var selectedAge: ParentalControlManager.ChildAge = .teenager
    @State private var selectedTimeLimit: ParentalControlManager.TimeLimit = .twoHours
    @State private var isProcessing = false
    
    enum SetupStep {
        case welcome, ageSelection, pinSetup, confirmation
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Mostrar errores si existen
                if let error = parentalControlManager.lastError {
                    VStack {
                        Text("Error detectado:")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Indicador de progreso
                ProgressView(value: progressValue, total: 4.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal)
                
                switch currentStep {
                case .welcome:
                    welcomeView
                case .ageSelection:
                    ageSelectionView
                case .pinSetup:
                    pinSetupView
                case .confirmation:
                    confirmationView
                }
                
                Spacer()
                
                // Botones de navegación
                HStack(spacing: 15) {
                    if currentStep != .welcome {
                        Button("Anterior") {
                            previousStep()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(isProcessing)
                    }
                    
                    Button(currentStep == .confirmation ? "Finalizar" : "Siguiente") {
                        nextStep()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!canProceed || isProcessing)
                    .overlay(
                        Group {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                        }
                    )
                }
                .padding()
            }
            .padding()
            .navigationTitle("Control Parental")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        if !isProcessing {
                            dismiss()
                        }
                    }
                    .disabled(isProcessing)
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
        .alert("Error en PIN", isPresented: $showingPinError) {
            Button("OK") {
                pinInput = ""
                confirmPin = ""
            }
        } message: {
            Text("Los PINs no coinciden. Inténtalo de nuevo.")
        }
        .alert("Configuración Completa", isPresented: $showingSuccess) {
            Button("Entendido") {
                dismiss()
            }
        } message: {
            Text("El control parental se ha activado exitosamente.")
        }
    }
    
    // ... (resto de las vistas sin cambios)
    
    private func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .ageSelection
        case .ageSelection:
            currentStep = .pinSetup
        case .pinSetup:
            if pinInput == confirmPin && pinInput.count == 4 {
                currentStep = .confirmation
            } else {
                showingPinError = true
            }
        case .confirmation:
            enableParentalControl()
        }
    }
    
    // FUNCIÓN CORREGIDA - TODAS LAS OPERACIONES EN HILO PRINCIPAL
    private func enableParentalControl() {
        print("DEBUG: enableParentalControl UI llamado")
        
        // Validar entrada
        guard pinInput.count == 4, pinInput.allSatisfy({ $0.isNumber }) else {
            errorMessage = "PIN debe tener 4 dígitos numéricos"
            showingError = true
            return
        }
        
        // Marcar como procesando
        isProcessing = true
        
        // Limpiar errores previos en el hilo principal
        parentalControlManager.lastError = nil
        
        // Configurar valores básicos inmediatamente en el hilo principal
        parentalControlManager.childAge = selectedAge
        parentalControlManager.dailyTimeLimit = selectedTimeLimit
        
        // Usar Task para operaciones async/await más seguras
        Task { @MainActor in
            do {
                // Habilitar control parental (esto debe ser sync en el hilo principal)
                try await enableParentalControlAsync()
                
                // Aplicar restricciones
                try await applyRestrictionsAsync()
                
                // Finalizar con éxito
                isProcessing = false
                showingSuccess = true
                
                print("DEBUG: Configuración completada exitosamente")
                
            } catch {
                print("ERROR: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                isProcessing = false
                showingError = true
            }
        }
    }
    
    // Función async para habilitar control parental
    @MainActor
    private func enableParentalControlAsync() async throws {
        print("DEBUG: Habilitando control parental...")
        
        // Estas operaciones ahora son síncronas en el hilo principal
        parentalControlManager.parentalPin = pinInput
        parentalControlManager.isPinSet = true
        parentalControlManager.isParentalControlEnabled = true
        
        // Aplicar restricciones por defecto
        parentalControlManager.restrictedCategories = selectedAge.restrictedCategories
        
        // Guardar configuración de forma síncrona
        try parentalControlManager.saveSettingsSync()
        
        print("DEBUG: Control parental habilitado correctamente")
    }
    
    // Función async para aplicar restricciones
    @MainActor
    private func applyRestrictionsAsync() async throws {
        print("DEBUG: Aplicando restricciones...")
        
        // Pequeña pausa para evitar sobrecargar el sistema
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        // Aplicar restricciones al app manager
        parentalControlManager.applyRestrictionsToAppManagerSync(appBlockingManager)
        
        print("DEBUG: Restricciones aplicadas correctamente")
    }
}

// MARK: - VISTAS AUXILIARES FALTANTES PARA PARENTAL CONTROL SETUP
extension ParentalControlSetupView {
    private var progressValue: Double {
        switch currentStep {
        case .welcome: return 1.0
        case .ageSelection: return 2.0
        case .pinSetup: return 3.0
        case .confirmation: return 4.0
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Control Parental")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Protege a tu hijo con controles inteligentes")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var ageSelectionView: some View {
        VStack(spacing: 20) {
            Text("Edad de tu hijo")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Esto nos ayuda a aplicar las restricciones apropiadas")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                ForEach(ParentalControlManager.ChildAge.allCases, id: \.self) { age in
                    AgeSelectionCard(
                        age: age,
                        isSelected: selectedAge == age
                    ) {
                        selectedAge = age
                        selectedTimeLimit = age.recommendedTimeLimit
                    }
                }
            }
        }
    }
    
    private var pinSetupView: some View {
        VStack(spacing: 20) {
            Text("PIN de Seguridad")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Crea un PIN de 4 dígitos")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("PIN:")
                        .font(.headline)
                    SecureField("Ingresa 4 dígitos", text: $pinInput)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: pinInput) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 4 {
                                pinInput = filtered
                            } else {
                                pinInput = String(filtered.prefix(4))
                            }
                        }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Confirmar PIN:")
                        .font(.headline)
                    SecureField("Confirma el PIN", text: $confirmPin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: confirmPin) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count <= 4 {
                                confirmPin = filtered
                            } else {
                                confirmPin = String(filtered.prefix(4))
                            }
                        }
                }
                
                if pinInput.count == 4 && confirmPin.count == 4 {
                    HStack {
                        Image(systemName: pinInput == confirmPin ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(pinInput == confirmPin ? .green : .red)
                        Text(pinInput == confirmPin ? "Los PINs coinciden" : "Los PINs no coinciden")
                            .font(.caption)
                            .foregroundColor(pinInput == confirmPin ? .green : .red)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var confirmationView: some View {
        VStack(spacing: 20) {
            Text("Resumen de Configuración")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                ConfirmationRow(title: "Edad del niño", value: selectedAge.rawValue)
                ConfirmationRow(title: "Límite diario", value: selectedTimeLimit.rawValue)
                ConfirmationRow(title: "Apps restringidas", value: "\(selectedAge.restrictedCategories.count) categorías")
                ConfirmationRow(title: "PIN configurado", value: "Sí")
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case .welcome: return true
        case .ageSelection: return true
        case .pinSetup: return pinInput.count == 4 && confirmPin.count == 4 && pinInput == confirmPin
        case .confirmation: return true
        }
    }
    
    private func previousStep() {
        switch currentStep {
        case .ageSelection:
            currentStep = .welcome
        case .pinSetup:
            currentStep = .ageSelection
        case .confirmation:
            currentStep = .pinSetup
        default:
            break
        }
    }
}

// MARK: - COMPONENTES AUXILIARES (sin cambios)
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

// MARK: - COMPONENTES AUXILIARES
struct AgeSelectionCard: View {
    let age: ParentalControlManager.ChildAge
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(age.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Límite sugerido: \(age.recommendedTimeLimit.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - App Usage Models
struct PopularApp: Identifiable {
    let id = UUID()
    let name: String
    let bundleId: String
    let urlScheme: String
    let icon: String
    let category: AppCategory
    var isInstalled: Bool = false
    var estimatedUsageMinutes: Int = 0
    var isBlocked: Bool = false
}

struct ConfirmationRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

enum AppCategory: String, CaseIterable {
    case social = "Redes Sociales"
    case entertainment = "Entretenimiento"
    case productivity = "Productividad"
    case games = "Juegos"
}

// MARK: - App Blocking Manager (Sin Family Controls)
class AppBlockingManager: ObservableObject {
    @Published var blockedApps: Set<String> = []
    @Published var blockedAppAttempts: [AppAttempt] = []
    @Published var dailyUsageLimits: [String: Int] = [:] // bundleId: minutes
    @Published var appUsageToday: [String: Int] = [:] // bundleId: minutes used
    @Published var isMonitoringEnabled = false
    @Published var showingBlockAlert = false
    @Published var currentBlockedApp: PopularApp?
    
    private let userDefaults = UserDefaults.standard
    private var monitoringTimer: Timer?
    
    struct AppAttempt: Identifiable {
        let id = UUID()
        let appName: String
        let bundleId: String
        let timestamp: Date
        let blocked: Bool
    }
    
    init() {
        loadBlockedApps()
        loadUsageLimits()
        setupNotifications()
        startMonitoring()
    }
    
    // MARK: - Persistence
    private func loadBlockedApps() {
        if let data = userDefaults.data(forKey: "blockedApps"),
           let apps = try? JSONDecoder().decode(Set<String>.self, from: data) {
            blockedApps = apps
        }
    }
    
    private func saveBlockedApps() {
        if let data = try? JSONEncoder().encode(blockedApps) {
            userDefaults.set(data, forKey: "blockedApps")
        }
    }
    
    private func loadUsageLimits() {
        dailyUsageLimits = userDefaults.object(forKey: "dailyUsageLimits") as? [String: Int] ?? [:]
        appUsageToday = userDefaults.object(forKey: "appUsageToday") as? [String: Int] ?? [:]
    }
    
    private func saveUsageLimits() {
        userDefaults.set(dailyUsageLimits, forKey: "dailyUsageLimits")
        userDefaults.set(appUsageToday, forKey: "appUsageToday")
    }
    
    // MARK: - App Blocking
    func blockApp(bundleId: String) {
        blockedApps.insert(bundleId)
        saveBlockedApps()
        
        // Registrar el bloqueo
        let attempt = AppAttempt(
            appName: getAppName(for: bundleId),
            bundleId: bundleId,
            timestamp: Date(),
            blocked: true
        )
        blockedAppAttempts.append(attempt)
        
        // Programar notificación de bloqueo
        scheduleBlockNotification(for: bundleId)
    }
    
    func unblockApp(bundleId: String) {
        blockedApps.remove(bundleId)
        saveBlockedApps()
        cancelBlockNotifications(for: bundleId)
    }
    
    func isAppBlocked(bundleId: String) -> Bool {
        return blockedApps.contains(bundleId)
    }
    
    func setDailyLimit(for bundleId: String, minutes: Int) {
        dailyUsageLimits[bundleId] = minutes
        saveUsageLimits()
    }
    
    func removeDailyLimit(for bundleId: String) {
        dailyUsageLimits.removeValue(forKey: bundleId)
        saveUsageLimits()
    }
    
    func hasExceededDailyLimit(bundleId: String) -> Bool {
        guard let limit = dailyUsageLimits[bundleId],
              let usage = appUsageToday[bundleId] else { return false }
        return usage >= limit
    }
    
    // MARK: - Monitoring
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notificaciones autorizadas")
            }
        }
    }
    
    private func startMonitoring() {
        isMonitoringEnabled = true
        
        // Monitorear cada 5 segundos cuando la app está activa
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.checkForBlockedAppUsage()
        }
    }
    
    func checkForBlockedAppUsage() {
        // Simular detección de apps (limitado por iOS)
        for bundleId in blockedApps {
            if canDetectAppRunning(bundleId: bundleId) {
                handleBlockedAppDetected(bundleId: bundleId)
            }
        }
    }
    
    private func canDetectAppRunning(bundleId: String) -> Bool {
        // Método limitado - iOS no permite detección directa
        // Esto es solo una simulación para demostración
        return Int.random(in: 1...100) <= 5 // 5% de probabilidad para demo
    }
    
    private func handleBlockedAppDetected(bundleId: String) {
        let appName = getAppName(for: bundleId)
        
        // Registrar intento
        let attempt = AppAttempt(
            appName: appName,
            bundleId: bundleId,
            timestamp: Date(),
            blocked: true
        )
        
        DispatchQueue.main.async {
            self.blockedAppAttempts.append(attempt)
            self.currentBlockedApp = self.createPopularApp(for: bundleId)
            self.showingBlockAlert = true
        }
        
        // Enviar notificación
        sendBlockedAppNotification(appName: appName)
    }
    
    // MARK: - Notifications
    private func scheduleBlockNotification(for bundleId: String) {
        let content = UNMutableNotificationContent()
        content.title = "App Bloqueada"
        content.body = "\(getAppName(for: bundleId)) ha sido bloqueada"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "block_\(bundleId)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendBlockedAppNotification(appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Aplicación Bloqueada"
        content.body = "Intento de abrir \(appName) detectado y bloqueado"
        content.sound = .default
        content.badge = NSNumber(value: blockedAppAttempts.count)
        
        let request = UNNotificationRequest(
            identifier: "blocked_attempt_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelBlockNotifications(for bundleId: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["block_\(bundleId)"])
    }
    
    // MARK: - Helpers
    private func getAppName(for bundleId: String) -> String {
        let appNames: [String: String] = [
            "com.zhiliaoapp.musically": "TikTok",
            "com.burbn.instagram": "Instagram",
            "com.facebook.Facebook": "Facebook",
            "com.google.ios.youtube": "YouTube",
            "com.netflix.Netflix": "Netflix",
            "com.roblox.robloxmobile": "Roblox",
            "net.whatsapp.WhatsApp": "WhatsApp",
            "com.toyopagroup.picaboo": "Snapchat",
            "com.atebits.Tweetie2": "Twitter/X",
            "com.spotify.client": "Spotify",
            "com.disney.disneyplus": "Disney+",
            "com.mojang.minecraftpe": "Minecraft",
            "com.innersloth.amongus": "Among Us",
            "com.epicgames.fortnite": "Fortnite",
            "com.google.chrome.ios": "Google Chrome",
            "com.microsoft.Office.Word": "Microsoft Word"
        ]
        return appNames[bundleId] ?? "App Desconocida"
    }
    
    private func createPopularApp(for bundleId: String) -> PopularApp {
        return PopularApp(
            name: getAppName(for: bundleId),
            bundleId: bundleId,
            urlScheme: "",
            icon: getAppIcon(for: bundleId),
            category: getAppCategory(for: bundleId)
        )
    }
    
    private func getAppIcon(for bundleId: String) -> String {
        let appIcons: [String: String] = [
            "com.zhiliaoapp.musically": "📱",
            "com.burbn.instagram": "📷",
            "com.facebook.Facebook": "👥",
            "com.google.ios.youtube": "📺",
            "com.netflix.Netflix": "🎬",
            "com.roblox.robloxmobile": "🎮",
            "net.whatsapp.WhatsApp": "💬",
            "com.toyopagroup.picaboo": "👻",
            "com.atebits.Tweetie2": "🐦",
            "com.spotify.client": "🎵",
            "com.disney.disneyplus": "🏰",
            "com.mojang.minecraftpe": "⛏️",
            "com.innersloth.amongus": "👾",
            "com.epicgames.fortnite": "🏆",
            "com.google.chrome.ios": "🌐",
            "com.microsoft.Office.Word": "📝"
        ]
        return appIcons[bundleId] ?? "📱"
    }
    
    private func getAppCategory(for bundleId: String) -> AppCategory {
        let gameApps = ["com.roblox.robloxmobile", "com.mojang.minecraftpe", "com.innersloth.amongus", "com.epicgames.fortnite"]
        let socialApps = ["com.zhiliaoapp.musically", "com.burbn.instagram", "com.facebook.Facebook", "net.whatsapp.WhatsApp", "com.toyopagroup.picaboo", "com.atebits.Tweetie2"]
        let entertainmentApps = ["com.google.ios.youtube", "com.netflix.Netflix", "com.spotify.client", "com.disney.disneyplus"]
        let productivityApps = ["com.google.chrome.ios", "com.microsoft.Office.Word"]
        
        if gameApps.contains(bundleId) { return .games }
        if socialApps.contains(bundleId) { return .social }
        if entertainmentApps.contains(bundleId) { return .entertainment }
        if productivityApps.contains(bundleId) { return .productivity }
        
        return .social
    }
}

// MARK: - App Detection Manager
class AppDetectionManager: ObservableObject {
    @Published var popularApps: [PopularApp] = []
    @Published var hasScreenTimePermission = false
    
    init() {
        setupPopularApps()
        checkScreenTimePermission()
    }
    
    private func setupPopularApps() {
        popularApps = [
            // Redes Sociales
            PopularApp(name: "TikTok", bundleId: "com.zhiliaoapp.musically", urlScheme: "tiktok://", icon: "📱", category: .social),
            PopularApp(name: "Instagram", bundleId: "com.burbn.instagram", urlScheme: "instagram://", icon: "📷", category: .social),
            PopularApp(name: "Facebook", bundleId: "com.facebook.Facebook", urlScheme: "fb://", icon: "👥", category: .social),
            PopularApp(name: "WhatsApp", bundleId: "net.whatsapp.WhatsApp", urlScheme: "whatsapp://", icon: "💬", category: .social),
            PopularApp(name: "Snapchat", bundleId: "com.toyopagroup.picaboo", urlScheme: "snapchat://", icon: "👻", category: .social),
            PopularApp(name: "Twitter/X", bundleId: "com.atebits.Tweetie2", urlScheme: "twitter://", icon: "🐦", category: .social),
            
            // Entretenimiento
            PopularApp(name: "YouTube", bundleId: "com.google.ios.youtube", urlScheme: "youtube://", icon: "📺", category: .entertainment),
            PopularApp(name: "Netflix", bundleId: "com.netflix.Netflix", urlScheme: "nflx://", icon: "🎬", category: .entertainment),
            PopularApp(name: "Spotify", bundleId: "com.spotify.client", urlScheme: "spotify://", icon: "🎵", category: .entertainment),
            PopularApp(name: "Disney+", bundleId: "com.disney.disneyplus", urlScheme: "disneyplus://", icon: "🏰", category: .entertainment),
            
            // Juegos
            PopularApp(name: "Roblox", bundleId: "com.roblox.robloxmobile", urlScheme: "roblox://", icon: "🎮", category: .games),
            PopularApp(name: "Minecraft", bundleId: "com.mojang.minecraftpe", urlScheme: "minecraft://", icon: "⛏️", category: .games),
            PopularApp(name: "Among Us", bundleId: "com.innersloth.amongus", urlScheme: "amongus://", icon: "👾", category: .games),
            PopularApp(name: "Fortnite", bundleId: "com.epicgames.fortnite", urlScheme: "fortnite://", icon: "🏆", category: .games),
            
            // Productividad
            PopularApp(name: "Google Chrome", bundleId: "com.google.chrome.ios", urlScheme: "googlechrome://", icon: "🌐", category: .productivity),
            PopularApp(name: "Microsoft Word", bundleId: "com.microsoft.Office.Word", urlScheme: "ms-word://", icon: "📝", category: .productivity),
        ]
        
        detectInstalledApps()
    }
    
    func detectInstalledApps() {
        for i in 0..<popularApps.count {
            if let url = URL(string: popularApps[i].urlScheme) {
                popularApps[i].isInstalled = UIApplication.shared.canOpenURL(url)
                
                if popularApps[i].isInstalled {
                    popularApps[i].estimatedUsageMinutes = Int.random(in: 10...180)
                }
            }
        }
    }
    
    private func checkScreenTimePermission() {
        hasScreenTimePermission = false
    }
    
    func requestScreenTimePermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hasScreenTimePermission = true
        }
    }
    
    func openApp(_ app: PopularApp) {
        if let url = URL(string: app.urlScheme) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - App Blocking View
struct AppBlockingView: View {
    @StateObject private var appManager = AppDetectionManager()
    @EnvironmentObject var blockingManager: AppBlockingManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    Text("🔒 Control de Aplicaciones")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Gestiona el acceso a aplicaciones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Tabs
                Picker("Vista", selection: $selectedTab) {
                    Text("Bloqueadas (\(blockingManager.blockedApps.count))").tag(0)
                    Text("Disponibles").tag(1)
                    Text("Actividad").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        blockedAppsView
                    case 1:
                        availableAppsView
                    case 2:
                        activityView
                    default:
                        blockedAppsView
                    }
                }
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("App Bloqueada", isPresented: $blockingManager.showingBlockAlert) {
                Button("Entendido") { }
                Button("Ver Detalles") {
                    selectedTab = 2 // Cambiar a la pestaña de actividad
                }
            } message: {
                if let app = blockingManager.currentBlockedApp {
                    Text("Se detectó un intento de abrir \(app.name). La aplicación está bloqueada.")
                }
            }
        }
    }
    
    private var blockedAppsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if blockingManager.blockedApps.isEmpty {
                    EmptyStateView(
                        icon: "lock.open",
                        title: "No hay apps bloqueadas",
                        subtitle: "Ve a la pestaña 'Disponibles' para bloquear aplicaciones"
                    )
                } else {
                    ForEach(Array(blockingManager.blockedApps), id: \.self) { bundleId in
                        if let app = appManager.popularApps.first(where: { $0.bundleId == bundleId }) {
                            BlockedAppCard(app: app)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private var availableAppsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let availableApps = appManager.popularApps.filter { $0.isInstalled && !blockingManager.isAppBlocked(bundleId: $0.bundleId) }
                
                if availableApps.isEmpty {
                    EmptyStateView(
                        icon: "apps.iphone",
                        title: "No hay apps disponibles",
                        subtitle: "No se encontraron aplicaciones instaladas para bloquear"
                    )
                } else {
                    ForEach(availableApps) { app in
                        AvailableAppCard(app: app)
                    }
                }
            }
            .padding()
        }
    }
    
    private var activityView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Estadísticas del día
                VStack(spacing: 10) {
                    Text("📊 Actividad de Hoy")
                        .font(.headline)
                        .padding(.bottom)
                    
                    HStack(spacing: 20) {
                        StatCard(
                            title: "Intentos Bloqueados",
                            value: "\(blockingManager.blockedAppAttempts.filter { Calendar.current.isDateInToday($0.timestamp) }.count)",
                            icon: "shield.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Apps Monitoreadas",
                            value: "\(blockingManager.blockedApps.count)",
                            icon: "eye.fill",
                            color: .blue
                        )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Lista de intentos recientes
                VStack(alignment: .leading, spacing: 10) {
                    Text("🚨 Intentos Recientes")
                        .font(.headline)
                    
                    if blockingManager.blockedAppAttempts.isEmpty {
                        Text("No hay intentos registrados")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(Array(blockingManager.blockedAppAttempts.suffix(10).reversed())) { attempt in
                            AttemptRow(attempt: attempt)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

// MARK: - Enhanced App List View
struct AppListView: View {
    @StateObject private var appManager = AppDetectionManager()
    @EnvironmentObject var blockingManager: AppBlockingManager
    @State private var selectedCategory: AppCategory? = nil
    
    var filteredApps: [PopularApp] {
        if let category = selectedCategory {
            return appManager.popularApps.filter { $0.category == category }
        }
        return appManager.popularApps
    }
    
    var installedApps: [PopularApp] {
        appManager.popularApps.filter { $0.isInstalled }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header con estadísticas
                statsHeader
                
                // Filtros por categoría
                categoryFilter
                
                // Lista de apps
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredApps) { app in
                            AppRowView(app: app, appManager: appManager)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Apps Populares")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Actualizar") {
                        appManager.detectInstalledApps()
                    }
                }
            }
        }
    }
    
    private var statsHeader: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Apps Instaladas",
                    value: "\(installedApps.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Apps Bloqueadas",
                    value: "\(blockingManager.blockedApps.count)",
                    icon: "lock.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Más Usada",
                    value: mostUsedAppName,
                    icon: "star.fill",
                    color: .orange
                )
            }
            
            if !appManager.hasScreenTimePermission {
                Button("Activar Monitoreo") {
                    appManager.requestScreenTimePermission()
                }
                .buttonStyle(ScreenTimeButtonStyle())
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryChip(
                    title: "Todas",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }
                
                ForEach(AppCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
    }
    
    private var mostUsedAppName: String {
        let mostUsed = installedApps.max { $0.estimatedUsageMinutes < $1.estimatedUsageMinutes }
        return mostUsed?.name ?? "N/A"
    }
}

// MARK: - App Row View
struct AppRowView: View {
    let app: PopularApp
    let appManager: AppDetectionManager
    @EnvironmentObject var blockingManager: AppBlockingManager
    @State private var showingDetails = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icono de la app
            Text(app.icon)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(statusColor.opacity(0.2))
                )
            
            // Información de la app
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(app.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if app.isInstalled {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    
                    if blockingManager.isAppBlocked(bundleId: app.bundleId) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                Text(app.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if app.isInstalled && app.estimatedUsageMinutes > 0 {
                    Text("~\(app.estimatedUsageMinutes) min hoy")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 8) {
                if app.isInstalled {
                    if blockingManager.isAppBlocked(bundleId: app.bundleId) {
                        Button("Desbloq.") {
                            blockingManager.unblockApp(bundleId: app.bundleId)
                        }
                        .buttonStyle(MiniButtonStyle(color: .green))
                    } else {
                        Button("Abrir") {
                            appManager.openApp(app)
                        }
                        .buttonStyle(MiniButtonStyle(color: .blue))
                        
                        Button("Bloquear") {
                            blockingManager.blockApp(bundleId: app.bundleId)
                        }
                        .buttonStyle(MiniButtonStyle(color: .red))
                    }
                } else {
                    Text("No instalada")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .sheet(isPresented: $showingDetails) {
            AppDetailsView(app: app)
        }
    }
    
    private var statusColor: Color {
        if blockingManager.isAppBlocked(bundleId: app.bundleId) {
            return .red
        } else if app.isInstalled {
            return .green
        } else {
            return .gray
        }
    }
}

// MARK: - Custom Card Components
struct BlockedAppCard: View {
    let app: PopularApp
    @EnvironmentObject var blockingManager: AppBlockingManager
    @State private var showingLimitSetter = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 15) {
                Text(app.icon)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.red.opacity(0.2)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("🔒 Bloqueada")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button("Desbloquear") {
                        blockingManager.unblockApp(bundleId: app.bundleId)
                    }
                    .buttonStyle(MiniButtonStyle(color: .green))
                    
                    Button("Límites") {
                        showingLimitSetter = true
                    }
                    .buttonStyle(MiniButtonStyle(color: .blue))
                }
            }
            
            // Información de límites si está configurado
            if let limit = blockingManager.dailyUsageLimits[app.bundleId] {
                limitProgressView(limit: limit)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingLimitSetter) {
            DailyLimitSetterView(app: app)
        }
    }
    
    // Función separada para el ProgressView
    private func limitProgressView(limit: Int) -> some View {
        let usage = blockingManager.appUsageToday[app.bundleId] ?? 0
        let progressValue = Double(usage)
        let totalValue = Double(limit)
        let percentage = Int((progressValue / totalValue) * 100)
        let isOverLimit = usage >= limit
        
        return ProgressView(value: progressValue, total: totalValue) {
            HStack {
                Text("Uso diario: \(usage)/\(limit) min")
                    .font(.caption)
                Spacer()
                Text("\(percentage)%")
                    .font(.caption)
            }
        }
        .tint(isOverLimit ? .red : .blue)
    }
}
struct AvailableAppCard: View {
    let app: PopularApp
    @EnvironmentObject var blockingManager: AppBlockingManager
    @State private var showingConfirmation = false
    
    var body: some View {
        HStack(spacing: 15) {
            Text(app.icon)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.green.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(app.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if app.estimatedUsageMinutes > 0 {
                    Text("~\(app.estimatedUsageMinutes) min hoy")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Button("Bloquear") {
                showingConfirmation = true
            }
            .buttonStyle(MiniButtonStyle(color: .red))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .alert("Confirmar Bloqueo", isPresented: $showingConfirmation) {
            Button("Cancelar", role: .cancel) { }
            Button("Bloquear", role: .destructive) {
                blockingManager.blockApp(bundleId: app.bundleId)
            }
        } message: {
            Text("¿Estás seguro de que quieres bloquear \(app.name)? Recibirás notificaciones cuando se intente abrir.")
        }
    }
}

struct AttemptRow: View {
    let attempt: AppBlockingManager.AppAttempt
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: attempt.blocked ? "xmark.shield.fill" : "checkmark.shield.fill")
                .foregroundColor(attempt.blocked ? .red : .green)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(attempt.appName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(attempt.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(attempt.blocked ? "Bloqueado" : "Permitido")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(attempt.blocked ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                )
                .foregroundColor(attempt.blocked ? .red : .green)
        }
        .padding(.vertical, 8)
    }
}

struct DailyLimitSetterView: View {
    let app: PopularApp
    @EnvironmentObject var blockingManager: AppBlockingManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMinutes = 60
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text(app.icon)
                        .font(.system(size: 60))
                    
                    Text(app.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                VStack(spacing: 15) {
                    Text("Límite Diario")
                        .font(.headline)
                    
                    Text("\(selectedMinutes) minutos")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Slider(value: .init(
                        get: { Double(selectedMinutes) },
                        set: { selectedMinutes = Int($0) }
                    ), in: 15...300, step: 15)
                    .accentColor(.blue)
                    
                    Text("De 15 minutos a 5 horas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Button("Establecer Límite") {
                    blockingManager.setDailyLimit(for: app.bundleId, minutes: selectedMinutes)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("Quitar Límite") {
                    blockingManager.removeDailyLimit(for: app.bundleId)
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
            }
            .padding()
            .navigationTitle("Límite Diario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .onAppear {
            selectedMinutes = blockingManager.dailyUsageLimits[app.bundleId] ?? 60
        }
    }
}

// MARK: - App Details View
struct AppDetailsView: View {
    let app: PopularApp
    @EnvironmentObject var blockingManager: AppBlockingManager
    @State private var dailyLimit: Double = 60
    @State private var isLimitEnabled = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text(app.icon)
                        .font(.system(size: 60))
                    
                    Text(app.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(app.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                VStack(spacing: 15) {
                    StatRow(title: "Tiempo hoy", value: "\(app.estimatedUsageMinutes) min")
                    StatRow(title: "Promedio semanal", value: "\(Int.random(in: 30...120)) min/día")
                    StatRow(title: "Veces abierta hoy", value: "\(Int.random(in: 5...25))")
                    StatRow(title: "Primera apertura", value: "08:30")
                    StatRow(title: "Última apertura", value: "21:15")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 15) {
                    Toggle("Activar límite diario", isOn: $isLimitEnabled)
                    
                    if isLimitEnabled {
                        VStack(spacing: 10) {
                            Text("Límite: \(Int(dailyLimit)) minutos")
                                .font(.headline)
                            
                            Slider(value: $dailyLimit, in: 15...180, step: 15)
                                .accentColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 10) {
                    if blockingManager.isAppBlocked(bundleId: app.bundleId) {
                        Button("Desbloquear \(app.name)") {
                            blockingManager.unblockApp(bundleId: app.bundleId)
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    } else {
                        Button("Abrir \(app.name)") {
                            if let url = URL(string: app.urlScheme) {
                                UIApplication.shared.open(url)
                            }
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button("Bloquear aplicación") {
                            blockingManager.blockApp(bundleId: app.bundleId)
                            dismiss()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Detalles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            isLimitEnabled = blockingManager.dailyUsageLimits[app.bundleId] != nil
            dailyLimit = Double(blockingManager.dailyUsageLimits[app.bundleId] ?? 60)
        }
        .onChange(of: isLimitEnabled) { _, newValue in
            if newValue {
                blockingManager.setDailyLimit(for: app.bundleId, minutes: Int(dailyLimit))
            } else {
                blockingManager.removeDailyLimit(for: app.bundleId)
            }
        }
        .onChange(of: dailyLimit) { _, newValue in
            if isLimitEnabled {
                blockingManager.setDailyLimit(for: app.bundleId, minutes: Int(newValue))
            }
        }
    }
}

// MARK: - Web Control View
struct WebControlView: View {
    @State private var blockedDomains: [String] = [
        "adult-site-example.com",
        "gambling-site.com",
        "violence-content.com"
    ]
    @State private var newDomain = ""
    @State private var showingSafari = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🛡️ Control de Navegación")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                InfoCard(
                    title: "Control Parental",
                    description: "Gestiona el acceso a contenido web inapropiado",
                    color: .red
                )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Sitios Bloqueados:")
                        .font(.headline)
                    
                    ForEach(blockedDomains, id: \.self) { domain in
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text(domain)
                            Spacer()
                            Button("Eliminar") {
                                blockedDomains.removeAll { $0 == domain }
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                HStack {
                    TextField("Nuevo dominio a bloquear", text: $newDomain)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Agregar") {
                        if !newDomain.isEmpty {
                            blockedDomains.append(newDomain)
                            newDomain = ""
                        }
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                
                Button("Configurar Restricciones del Sistema") {
                    showingSafari = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Text("⚠️ Nota: Para bloqueo real, configura desde Ajustes > Tiempo de Uso > Restricciones de Contenido")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Control Web")
        }
        .sheet(isPresented: $showingSafari) {
            SafariView(url: URL(string: "https://support.apple.com/es-es/HT201304")!)
        }
    }
}

// MARK: - Location Manager & View
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error obteniendo ubicación: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
    }
}

struct LocationView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("📍 Ubicación en Tiempo Real")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                   locationManager.authorizationStatus == .authorizedAlways {
                    
                    if let location = locationManager.location {
                        VStack(spacing: 15) {
                            InfoCard(
                                title: "Ubicación Actual",
                                description: "Coordenadas GPS obtenidas",
                                color: .green
                            )
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Latitud:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(location.coordinate.latitude, specifier: "%.6f")")
                                }
                                
                                HStack {
                                    Text("Longitud:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(location.coordinate.longitude, specifier: "%.6f")")
                                }
                                
                                HStack {
                                    Text("Precisión:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(location.horizontalAccuracy, specifier: "%.0f") m")
                                }
                                
                                HStack {
                                    Text("Timestamp:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(location.timestamp, style: .time)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    } else {
                        Text("Obteniendo ubicación...")
                            .foregroundColor(.gray)
                    }
                    
                } else {
                    VStack(spacing: 15) {
                        Text("📍 Permisos de Ubicación Requeridos")
                            .font(.headline)
                        
                        Text("Esta app necesita acceso a tu ubicación para funcionar correctamente.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        Button("Solicitar Permisos") {
                            locationManager.requestLocation()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                
                Button("Actualizar Ubicación") {
                    locationManager.requestLocation()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Spacer()
            }
            .padding()
            .navigationTitle("Ubicación")
        }
    }
}

// MARK: - Usage Limit View
struct UsageLimitView: View {
    @State private var dailyLimitHours = 2.0
    @State private var isLimitEnabled = false
    @State private var showingScreenTimeAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("⏱️ Límites de Uso")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                InfoCard(
                    title: "Control de Tiempo",
                    description: "Establece límites de uso del dispositivo",
                    color: .purple
                )
                
                VStack(spacing: 15) {
                    Toggle("Activar Límites", isOn: $isLimitEnabled)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    if isLimitEnabled {
                        VStack(spacing: 10) {
                            Text("Límite Diario: \(Int(dailyLimitHours)) horas")
                                .font(.headline)
                            
                            Slider(value: $dailyLimitHours, in: 1...8, step: 1)
                                .accentColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Button("Configurar Screen Time del Sistema") {
                    showingScreenTimeAlert = true
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Text("⚠️ Para control real del sistema, usar Tiempo de Uso en Ajustes de iOS")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Límites de Uso")
        }
        .alert("Screen Time", isPresented: $showingScreenTimeAlert) {
            Button("OK") { }
        } message: {
            Text("Ve a Ajustes > Tiempo de Uso para configurar límites reales del sistema")
        }
    }
}

// MARK: - Custom Components & Button Styles
struct InfoCard: View {
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 2)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct MiniButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ScreenTimeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.2))
            .foregroundColor(.green)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - PARENTAL CONTROL MANAGER CORREGIDO CON ENUMS
class ParentalControlManager: ObservableObject {
    @Published var isParentalControlEnabled = false
    @Published var childAge: ChildAge = .teenager
    @Published var restrictedCategories: Set<AppCategory> = []
    @Published var parentalPin = ""
    @Published var isPinSet = false
    @Published var dailyTimeLimit: TimeLimit = .twoHours
    @Published var lastError: String? = nil
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - ENUMS FALTANTES
    enum ChildAge: String, CaseIterable {
        case child = "Niño (6-10 años)"
        case preteen = "Preadolescente (11-12 años)"
        case teenager = "Adolescente (13-17 años)"
        
        var recommendedTimeLimit: TimeLimit {
            switch self {
            case .child: return .oneHour
            case .preteen: return .twoHours
            case .teenager: return .threeHours
            }
        }
        
        var restrictedCategories: Set<AppCategory> {
            switch self {
            case .child:
                return [.social, .entertainment]
            case .preteen:
                return [.social]
            case .teenager:
                return []
            }
        }
    }
    
    enum TimeLimit: String, CaseIterable {
        case thirtyMinutes = "30 minutos"
        case oneHour = "1 hora"
        case twoHours = "2 horas"
        case threeHours = "3 horas"
        case fourHours = "4 horas"
        case unlimited = "Sin límite"
        
        var minutes: Int {
            switch self {
            case .thirtyMinutes: return 30
            case .oneHour: return 60
            case .twoHours: return 120
            case .threeHours: return 180
            case .fourHours: return 240
            case .unlimited: return 0
            }
        }
    }
    
    init() {
        print("DEBUG: Inicializando ParentalControlManager")
        loadSettingsSync()
    }
    
    // VERSIÓN SÍNCRONA Y SEGURA DE GUARDADO
    func saveSettingsSync() throws {
        print("DEBUG: Guardando configuración de forma síncrona...")
        
        // Asegurar que estamos en el hilo principal
        guard Thread.isMainThread else {
            throw ParentalControlError.saveFailed("saveSettingsSync debe llamarse desde el hilo principal")
        }
        
        // Guardar todas las configuraciones
        userDefaults.set(isParentalControlEnabled, forKey: "parentalControlEnabled")
        userDefaults.set(parentalPin, forKey: "parentalPin")
        userDefaults.set(isPinSet, forKey: "pinSet")
        userDefaults.set(childAge.rawValue, forKey: "childAge")
        userDefaults.set(dailyTimeLimit.rawValue, forKey: "dailyTimeLimit")
        
        // Convertir categorías a strings
        let categoryStrings = restrictedCategories.map { $0.rawValue }
        userDefaults.set(categoryStrings, forKey: "restrictedCategories")
        
        // Sincronizar inmediatamente
        let success = userDefaults.synchronize()
        if !success {
            throw ParentalControlError.saveFailed("Error sincronizando UserDefaults")
        }
        
        print("DEBUG: Configuración guardada correctamente")
    }
    
    // VERSIÓN SÍNCRONA Y SEGURA DE CARGA
    private func loadSettingsSync() {
        print("DEBUG: Cargando configuración...")
        
        // Cargar configuraciones
        isParentalControlEnabled = userDefaults.bool(forKey: "parentalControlEnabled")
        parentalPin = userDefaults.string(forKey: "parentalPin") ?? ""
        isPinSet = userDefaults.bool(forKey: "pinSet")
        
        // Cargar edad
        if let ageString = userDefaults.string(forKey: "childAge"),
           let age = ChildAge(rawValue: ageString) {
            childAge = age
        }
        
        // Cargar límite de tiempo
        if let limitString = userDefaults.string(forKey: "dailyTimeLimit"),
           let limit = TimeLimit(rawValue: limitString) {
            dailyTimeLimit = limit
        }
        
        // Cargar categorías restringidas
        if let categoryStrings = userDefaults.array(forKey: "restrictedCategories") as? [String] {
            restrictedCategories = Set(categoryStrings.compactMap { AppCategory(rawValue: $0) })
        }
        
        print("DEBUG: Configuración cargada - Control parental: \(isParentalControlEnabled)")
    }
    
    // VERSIÓN SÍNCRONA PARA APLICAR RESTRICCIONES
    func applyRestrictionsToAppManagerSync(_ appBlockingManager: AppBlockingManager) {
        print("DEBUG: Aplicando restricciones de forma síncrona...")
        
        guard isParentalControlEnabled else {
            print("DEBUG: Control parental no habilitado")
            return
        }
        
        let socialApps = [
            "com.zhiliaoapp.musically",
            "com.burbn.instagram",
            "com.facebook.Facebook",
            "net.whatsapp.WhatsApp",
            "com.toyopagroup.picaboo",
            "com.atebits.Tweetie2"
        ]
        
        let entertainmentApps = [
            "com.google.ios.youtube",
            "com.netflix.Netflix",
            "com.spotify.client",
            "com.disney.disneyplus"
        ]
        
        var appsToBlock: [String] = []
        
        if restrictedCategories.contains(.social) {
            appsToBlock.append(contentsOf: socialApps)
        }
        
        if restrictedCategories.contains(.entertainment) {
            appsToBlock.append(contentsOf: entertainmentApps)
        }
        
        print("DEBUG: Bloqueando \(appsToBlock.count) apps...")
        
        // Bloquear apps de forma síncrona
        for bundleId in appsToBlock {
            appBlockingManager.blockApp(bundleId: bundleId)
        }
        
        print("DEBUG: Restricciones aplicadas correctamente")
    }
}

// MARK: - ERRORES PERSONALIZADOS
enum ParentalControlError: LocalizedError {
    case invalidPin(String)
    case configurationFailed(String)
    case saveFailed(String)
    case loadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidPin(let message): return "PIN inválido: \(message)"
        case .configurationFailed(let message): return "Error de configuración: \(message)"
        case .saveFailed(let message): return "Error de guardado: \(message)"
        case .loadFailed(let message): return "Error de carga: \(message)"
        }
    }
}
