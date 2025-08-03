import SwiftUI
import CoreData

public struct SettingsView: View {
    @Binding var colorScheme: ColorScheme?
    @State private var selectedTheme: Int = 0
    @State private var showingDataAlert = false
    @State private var alertMessage = ""
    @State private var isSyncing = false
    @StateObject private var githubService = GitHubDataService.shared
    
    public init(colorScheme: Binding<ColorScheme?>) {
        self._colorScheme = colorScheme
    }
    
    public var body: some View {
        Form {
            Section(header: Text(LocalizedStringKey("settings_theme"))) {
                Picker(selection: $selectedTheme, label: Text(LocalizedStringKey("settings_theme_mode"))) {
                    Text(LocalizedStringKey("settings_theme_system")).tag(0)
                    Text(LocalizedStringKey("settings_theme_light")).tag(1)
                    Text(LocalizedStringKey("settings_theme_dark")).tag(2)
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
            
            Section(header: Text(LocalizedStringKey("settings_data"))) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(LocalizedStringKey("settings_sync_data"))
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
                        Text(LocalizedStringKey("settings_last_sync"))
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
                        Text(LocalizedStringKey("settings_sync_now"))
                    }
                }
                .disabled(isSyncing || githubService.isDownloading)
            }
        }
        .navigationTitle(LocalizedStringKey("settings"))
        .onAppear {
            if colorScheme == .light { selectedTheme = 1 }
            else if colorScheme == .dark { selectedTheme = 2 }
            else { selectedTheme = 0 }
        }
        .alert(LocalizedStringKey("settings_sync_result"), isPresented: $showingDataAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func syncData() {
        isSyncing = true
        
        Task {
            do {
                try await CoreDataService.shared.syncDataFromGitHub()
                await MainActor.run {
                    alertMessage = NSLocalizedString("settings_sync_success", comment: "")
                    showingDataAlert = true
                    isSyncing = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = NSLocalizedString("settings_sync_error", comment: "") + ": \(error.localizedDescription)"
                    showingDataAlert = true
                    isSyncing = false
                }
            }
        }
    }
} 
