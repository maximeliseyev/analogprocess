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
        return "v\(version)"
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
            
            Section(header: Text("Support")) {
                Button(action: contactDeveloper) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Contact Developer")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .foregroundColor(.primary)
            }
            
        }
        .navigationTitle(LocalizedStringKey("settings"))
        .overlay(
            VStack {
                Spacer()
                Text(appVersion)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        )
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
    
    private func contactDeveloper() {
        let email = Constants.Developer.email
        let subject = "Analog Process App Feedback"
        let body = "Hello,\n\nI would like to provide feedback about the Analog Process app.\n\n"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            UIApplication.shared.open(url)
        }
    }
} 
