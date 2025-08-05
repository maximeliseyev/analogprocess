//
//  CloudKitTestView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CloudKitTestView: View {
    @StateObject private var cloudKitService = CloudKitService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("CloudKit Test")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: cloudKitService.isCloudAvailable ? "icloud" : "icloud.slash")
                        .foregroundColor(cloudKitService.isCloudAvailable ? .blue : .gray)
                    Text("iCloud Status: \(cloudKitService.isCloudAvailable ? "Available" : "Not Available")")
                }
                
                HStack {
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                    Text("Sync Status: \(statusText)")
                }
                
                if let lastSync = cloudKitService.lastSyncDate {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text("Last Sync: \(lastSync, style: .relative)")
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Button("Request Cloud Access") {
                cloudKitService.requestCloudAccess()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Test Sync") {
                Task {
                    await cloudKitService.syncRecords()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(cloudKitService.syncStatus == .syncing)
            
            Spacer()
        }
        .padding()
        .alert("CloudKit Test", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var statusIcon: String {
        switch cloudKitService.syncStatus {
        case .idle:
            return "icloud"
        case .syncing:
            return "icloud.and.arrow.up"
        case .completed:
            return "checkmark.icloud"
        case .failed:
            return "exclamationmark.icloud"
        }
    }
    
    private var statusColor: Color {
        switch cloudKitService.syncStatus {
        case .idle:
            return .blue
        case .syncing:
            return .orange
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
    
    private var statusText: String {
        switch cloudKitService.syncStatus {
        case .idle:
            return "Idle"
        case .syncing:
            return "Syncing..."
        case .completed:
            return "Completed"
        case .failed(let error):
            return "Failed: \(error)"
        }
    }
}

#Preview {
    CloudKitTestView()
} 