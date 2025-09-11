//
//  SwiftDataIntegrationTestView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct SwiftDataIntegrationTestView: View {
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var filmsCount = 0
    @State private var developersCount = 0
    @State private var fixersCount = 0
    
    @StateObject private var swiftDataService: SwiftDataService
    
    init() {
        let container = SwiftDataPersistence.preview.modelContainer
        let githubService = GitHubDataService()
        let service = SwiftDataService(githubDataService: githubService, modelContainer: container)
        self._swiftDataService = StateObject(wrappedValue: service)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("SwiftData Integration Test")
                    .font(.title)
                    .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Data Count:")
                        .font(.headline)
                    Text("Films: \(filmsCount)")
                    Text("Developers: \(developersCount)")
                    Text("Fixers: \(fixersCount)")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                if isLoading {
                    ProgressView("Syncing with GitHub...")
                        .padding()
                }
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                
                if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
                
                VStack(spacing: 15) {
                    Button("Sync with GitHub") {
                        syncWithGitHub()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading)
                    
                    Button("Refresh Counts") {
                        refreshCounts()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading)
                    
                    Button("Clear All Data") {
                        clearAllData()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .disabled(isLoading)
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                refreshCounts()
            }
        }
    }
    
    private func syncWithGitHub() {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                try await swiftDataService.syncDataFromGitHub()
                await MainActor.run {
                    successMessage = "Successfully synced with GitHub!"
                    refreshCounts()
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func refreshCounts() {
        filmsCount = swiftDataService.getFilms().count
        developersCount = swiftDataService.getDevelopers().count
        fixersCount = swiftDataService.getFixers().count
    }
    
    private func clearAllData() {
        swiftDataService.clearAllData()
        refreshCounts()
        successMessage = "All data cleared"
    }
}

#Preview {
    SwiftDataIntegrationTestView()
}
