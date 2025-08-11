//
//  JournalView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    
    let onEditRecord: (SwiftDataCalculationRecord) -> Void
    let onDeleteRecord: (SwiftDataCalculationRecord) -> Void
    let onClose: () -> Void
    let onCreateNew: () -> Void
    let syncStatus: CloudKitService.SyncStatus
    let isCloudAvailable: Bool
    let onSync: () -> Void
    
    @State private var selectedRecord: SwiftDataCalculationRecord?
    
    init(onEditRecord: @escaping (SwiftDataCalculationRecord) -> Void, 
         onDeleteRecord: @escaping (SwiftDataCalculationRecord) -> Void,
         onClose: @escaping () -> Void, 
         onCreateNew: @escaping () -> Void,
         syncStatus: CloudKitService.SyncStatus = .idle,
         isCloudAvailable: Bool = false,
         onSync: @escaping () -> Void = {}) {
        self.onEditRecord = onEditRecord
        self.onDeleteRecord = onDeleteRecord
        self.onClose = onClose
        self.onCreateNew = onCreateNew
        self.syncStatus = syncStatus
        self.isCloudAvailable = isCloudAvailable
        self.onSync = onSync
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Статус синхронизации
            SyncStatusView(
                syncStatus: syncStatus,
                isCloudAvailable: isCloudAvailable,
                onSync: onSync
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            if $viewModel.savedRecords.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedStringKey("noRecords"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(LocalizedStringKey("noRecordsDescription"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.savedRecords, id: \.id) { record in
                            RecordRowView(
                                record: record,
                                onTap: {
                                    selectedRecord = record
                                }
                            )
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    onEditRecord(record)
                                } label: {
                                    Label(LocalizedStringKey("edit"), systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    onDeleteRecord(record)
                                } label: {
                                    Label(LocalizedStringKey("delete"), systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("journal"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRecord) { record in
            RecordDetailView(
                record: record,
                onEdit: {
                    selectedRecord = nil
                    onEditRecord(record)
                },
                onDelete: {
                    selectedRecord = nil
                    onDeleteRecord(record)
                }
            )
        }
        .onAppear {
            viewModel.loadRecords()
        }
    }
}


