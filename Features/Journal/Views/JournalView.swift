//
//  JournalView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import SwiftData

struct JournalView: View {
    @StateObject private var viewModel: JournalViewModel
    
    let onEditRecord: (SwiftDataJournalRecord) -> Void
    let onDeleteRecord: (SwiftDataJournalRecord) -> Void
    let onClose: () -> Void
    let onCreateNew: () -> Void
    let syncStatus: CloudKitService.SyncStatus
    let isCloudAvailable: Bool
    let onSync: () -> Void
    
    @State private var selectedRecord: SwiftDataJournalRecord?
    @State private var searchText = ""

    // MARK: - Computed Properties

    var filteredRecords: [SwiftDataJournalRecord] {
        if searchText.isEmpty {
            return viewModel.savedRecords
        } else {
            return viewModel.savedRecords.filter { record in
                let searchQuery = searchText.lowercased()

                let name = record.name?.lowercased() ?? ""
                let filmName = record.filmName?.lowercased() ?? ""
                let developerName = record.developerName?.lowercased() ?? ""
                let process = record.process?.lowercased() ?? ""
                let comment = record.comment?.lowercased() ?? ""

                return name.contains(searchQuery) ||
                       filmName.contains(searchQuery) ||
                       developerName.contains(searchQuery) ||
                       process.contains(searchQuery) ||
                       comment.contains(searchQuery)
            }
        }
    }

    init(swiftDataService: SwiftDataService,
         cloudKitService: CloudKitService,
         onEditRecord: @escaping (SwiftDataJournalRecord) -> Void, 
         onDeleteRecord: @escaping (SwiftDataJournalRecord) -> Void,
         onClose: @escaping () -> Void, 
         onCreateNew: @escaping () -> Void,
         syncStatus: CloudKitService.SyncStatus = .idle,
         isCloudAvailable: Bool = false,
         onSync: @escaping () -> Void = {}) {
        self._viewModel = StateObject(wrappedValue: JournalViewModel(swiftDataService: swiftDataService, cloudKitService: cloudKitService))
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
            if filteredRecords.isEmpty && searchText.isEmpty {
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
            } else if filteredRecords.isEmpty && !searchText.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text(LocalizedStringKey("noResultsFound"))
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(LocalizedStringKey("trySearchingDifferentKeywords"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredRecords, id: \.id) { record in
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
        .searchable(text: $searchText, prompt: String(localized: "searchJournal"))
        .sheet(item: $selectedRecord) { record in
            RecordDetailView(
                record: record,
                swiftDataService: viewModel.swiftDataService,
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


