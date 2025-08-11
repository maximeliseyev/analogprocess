import SwiftUI


public struct SettingsView: View {
    @Binding var colorScheme: ColorScheme?
    @State private var selectedTheme: Int = 0
    @State private var showingDataAlert = false
    @State private var alertMessage = ""
    @State private var isSyncing = false
    @StateObject private var githubService = GitHubDataService.shared
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    public init(colorScheme: Binding<ColorScheme?>) {
        self._colorScheme = colorScheme
    }
    
    public var body: some View {
        Form {
            Section(header: Text(LocalizedStringKey("settingsTheme"))) {
                Picker(selection: $selectedTheme, label: Text(LocalizedStringKey("settingsThemeMode"))) {
                    Text(LocalizedStringKey("settingsThemeSystem")).tag(0)
                    Text(LocalizedStringKey("settingsThemeLight")).tag(1)
                    Text(LocalizedStringKey("settingsThemeDark")).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedTheme) { oldValue, newValue in
                    switch newValue {
                    case 1: colorScheme = .light
                    case 2: colorScheme = .dark
                    default: colorScheme = nil
                    }
                }
            }
            
            Section(header: Text(LocalizedStringKey("settingsData"))) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(LocalizedStringKey("settingsSyncData"))
                        Spacer()
                        if isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    if githubService.isDownloading {
                        ProgressView(value: githubService.downloadProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                    }
                    
                    if let lastSync = githubService.lastSyncDate {
                        Text(LocalizedStringKey("settingsLastSync"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastSync, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: syncData) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text(LocalizedStringKey("settingsSyncNow"))
                    }
                }
                .disabled(isSyncing || githubService.isDownloading)
            }
            
            Section(header: Text(LocalizedStringKey("settingsAbout"))) {
                HStack {
                    Text(LocalizedStringKey("settingsVersion"))
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("SwiftData Migration")) {
                NavigationLink("SwiftData Integration Test") {
                    SwiftDataIntegrationTestView()
                }
                
                Toggle("Use SwiftData Development View", isOn: .constant(false))
                    .onChange(of: false) { oldValue, newValue in
                        // TODO: Добавить переключение между версиями
                        print("SwiftData Development View toggle: \(newValue)")
                    }
                
                // NavigationLink("SwiftData UI Components Test") {
                //     SwiftDataUIComponentsTestView()
                // }
            }
        }
        .navigationTitle(LocalizedStringKey("settings"))
        .onAppear {
            if colorScheme == .light { selectedTheme = 1 }
            else if colorScheme == .dark { selectedTheme = 2 }
            else { selectedTheme = 0 }
        }
                        .alert(LocalizedStringKey("settingsSyncResult"), isPresented: $showingDataAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func syncData() {
        isSyncing = true
        
        Task {
            do {
                try await SwiftDataService.shared.syncDataFromGitHub()
                await MainActor.run {
                    alertMessage = NSLocalizedString("settingsSyncSuccess", comment: "")
                    showingDataAlert = true
                    isSyncing = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = NSLocalizedString("settingsSyncError", comment: "") + ": \(error.localizedDescription)"
                    showingDataAlert = true
                    isSyncing = false
                }
            }
        }
    }
} 
