//
//  JournalView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct JournalView: View {
    let records: [CalculationRecord]
    let onEditRecord: (CalculationRecord) -> Void
    let onDeleteRecord: (CalculationRecord) -> Void
    let onClose: () -> Void
    let onCreateNew: () -> Void
    let syncStatus: CloudKitService.SyncStatus
    let isCloudAvailable: Bool
    let onSync: () -> Void
    
    @State private var selectedRecord: CalculationRecord?
    
    init(records: [CalculationRecord], 
         onEditRecord: @escaping (CalculationRecord) -> Void, 
         onDeleteRecord: @escaping (CalculationRecord) -> Void, 
         onClose: @escaping () -> Void, 
         onCreateNew: @escaping () -> Void,
         syncStatus: CloudKitService.SyncStatus = .idle,
         isCloudAvailable: Bool = false,
         onSync: @escaping () -> Void = {}) {
        self.records = records
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
            
            if records.isEmpty {
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
                        ForEach(records, id: \.id) { record in
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
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        JournalView(
            records: [
                // Моковая запись 1
                {
                    let record = CalculationRecord(context: PersistenceController.preview.container.viewContext)
                    record.name = "Портрет в парке"
                    record.filmName = "Kodak T-Max 400"
                    record.developerName = "Kodak Xtol"
                    record.dilution = "1+1"
                    record.iso = 400
                    record.temperature = 20.0
                    record.time = 420 // 7 минут
                    record.date = Date().addingTimeInterval(-86400) // Вчера
                    record.comment = "Отличные результаты, хорошая детализация теней"
                    return record
                }(),
                
                // Моковая запись 2
                {
                    let record = CalculationRecord(context: PersistenceController.preview.container.viewContext)
                    record.name = "Городской пейзаж"
                    record.filmName = "Ilford HP5 Plus"
                    record.developerName = "Ilford ID-11"
                    record.dilution = "1+1"
                    record.iso = 400
                    record.temperature = 20.0
                    record.time = 600 // 10 минут
                    record.date = Date().addingTimeInterval(-172800) // 2 дня назад
                    record.comment = "Классический ч/б, хороший контраст"
                    return record
                }(),
                
                // Моковая запись 3
                {
                    let record = CalculationRecord(context: PersistenceController.preview.container.viewContext)
                    record.name = "Быстрый тест"
                    record.filmName = "Test Film"
                    record.developerName = "Test Developer"
                    record.dilution = ""
                    record.iso = 100
                    record.temperature = 0.0
                    record.time = 180 // 3 минуты
                    record.date = Date()
                    record.comment = nil
                    return record
                }()
            ],
            onEditRecord: { record in
                print("Edit record: \(record.name ?? "Unknown")")
            },
            onDeleteRecord: { record in
                print("Delete record: \(record.name ?? "Unknown")")
            },
            onClose: {
                print("Close journal")
            },
            onCreateNew: {
                print("Create new record")
            },
            syncStatus: .completed,
            isCloudAvailable: true,
            onSync: {
                print("Sync with CloudKit")
            }
        )
    }
}

#Preview("Empty Journal") {
    NavigationStack {
        JournalView(
            records: [],
            onEditRecord: { record in
                print("Edit record: \(record.name ?? "Unknown")")
            },
            onDeleteRecord: { record in
                print("Delete record: \(record.name ?? "Unknown")")
            },
            onClose: {
                print("Close journal")
            },
            onCreateNew: {
                print("Create new record")
            },
            syncStatus: .idle,
            isCloudAvailable: false,
            onSync: {
                print("Sync with CloudKit")
            }
        )
    }
}
