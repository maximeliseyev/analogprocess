//
//  SyncStatusView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct SyncStatusView: View {
    let syncStatus: CloudKitService.SyncStatus
    let isCloudAvailable: Bool
    let onSync: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Иконка статуса
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.system(size: 14, weight: .medium))
            
            // Текст статуса
            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)
            
            Spacer()
            
            // Кнопка синхронизации
            if isCloudAvailable {
                Button(action: onSync) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                .disabled(syncStatus == .syncing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Computed Properties
    
    private var statusIcon: String {
        switch syncStatus {
        case .idle:
            return isCloudAvailable ? "icloud" : "icloud.slash"
        case .syncing:
            return "icloud.and.arrow.up"
        case .completed:
            return "checkmark.icloud"
        case .failed:
            return "exclamationmark.icloud"
        }
    }
    
    private var statusColor: Color {
        switch syncStatus {
        case .idle:
            return isCloudAvailable ? .blue : .gray
        case .syncing:
            return .orange
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
    
    private var statusText: String {
        switch syncStatus {
        case .idle:
            return isCloudAvailable ? NSLocalizedString("iCloudSyncStatusIdleAvailable", comment: "") : NSLocalizedString("iCloudSyncStatusIdleUnavailable", comment: "")
        case .syncing:
            return NSLocalizedString("iCloudSyncStatusSyncing", comment: "")
        case .completed:
            return NSLocalizedString("iCloudSyncStatusCompleted", comment: "")
        case .failed(let error):
            return String(format: NSLocalizedString("iCloudSyncCtatusFailed", comment: ""), error)
        }
    }
}
