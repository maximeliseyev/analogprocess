//
//  GitHubSyncExample.swift
//  FilmLab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// Пример использования GitHub синхронизации в приложении
struct GitHubSyncExample: View {
    @StateObject private var githubService = GitHubDataService.shared
    @State private var showingSyncAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("GitHub Data Sync Example")
                .font(.title)
                .padding()
            
            // Статус синхронизации
            VStack(alignment: .leading, spacing: 8) {
                Text("Sync Status:")
                    .font(.headline)
                
                HStack {
                    Text("Last sync:")
                    Spacer()
                    if let lastSync = githubService.lastSyncDate {
                        Text(lastSync, style: .relative)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Never")
                            .foregroundColor(.secondary)
                    }
                }
                
                if githubService.isDownloading {
                    ProgressView(value: githubService.downloadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                    Text("Downloading: \(Int(githubService.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Кнопка синхронизации
            Button(action: performSync) {
                HStack {
                    if githubService.isDownloading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text("Sync Data from GitHub")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(githubService.isDownloading)
            
            // Информация о данных
            VStack(alignment: .leading, spacing: 8) {
                Text("Data Sources:")
                    .font(.headline)
                
                Text("• Films: https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main/films.json")
                Text("• Developers: https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main/developers.json")
                Text("• Development Times: https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main/development-times.json")
                Text("• Temperature Multipliers: https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main/temperature-multipliers.json")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .alert("Sync Result", isPresented: $showingSyncAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func performSync() {
        Task {
            do {
                try await CoreDataService.shared.syncDataFromGitHub()
                await MainActor.run {
                    alertMessage = "Data synchronized successfully!"
                    showingSyncAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "Sync failed: \(error.localizedDescription)"
                    showingSyncAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GitHubSyncExample()
} 