//
//  AutoSyncTestView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct AutoSyncTestView: View {
    @StateObject private var autoSyncService = AutoSyncService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Auto Sync Test")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Статус автосинхронизации
                AutoSyncStatusView(autoSyncService: autoSyncService)
                    .padding()
                
                // Информация о последней синхронизации
                VStack(alignment: .leading, spacing: 12) {
                    if let lastAutoSync = autoSyncService.lastAutoSyncDate {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                            Text("Last Auto Sync: \(lastAutoSync, style: .relative)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: autoSyncService.isAutoSyncing ? "arrow.clockwise" : "checkmark.circle")
                            .foregroundColor(autoSyncService.isAutoSyncing ? .blue : .green)
                        Text(autoSyncService.isAutoSyncing ? "Auto-syncing..." : "Ready")
                            .font(.caption)
                            .foregroundColor(autoSyncService.isAutoSyncing ? .blue : .green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Переключатель автосинхронизации
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Enable Auto Sync", isOn: Binding(
                        get: { autoSyncService.isAutoSyncEnabled },
                        set: { autoSyncService.setAutoSyncEnabled($0) }
                    ))
                    .padding(.horizontal)
                }
                
                // Кнопки управления
                VStack(spacing: 12) {
                    Button("Simulate App Launch") {
                        autoSyncService.performAutoSyncOnAppLaunch()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!autoSyncService.isAutoSyncEnabled)
                    
                    Button("Force Auto Sync") {
                        Task {
                            await autoSyncService.forceAutoSync()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(autoSyncService.isAutoSyncing)
                    
                    Button("Reset Last Sync Date") {
                        UserDefaults.standard.removeObject(forKey: "LastAutoSyncDate")
                        autoSyncService.lastAutoSyncDate = nil
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Auto Sync Test")
            .alert("Auto Sync Test", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    AutoSyncTestView()
}
