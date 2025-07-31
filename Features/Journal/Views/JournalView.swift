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
    let onLoadRecord: (CalculationRecord) -> Void
    let onDeleteRecord: (CalculationRecord) -> Void
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    List {
                        ForEach(records, id: \.id) { record in
                            RecordRowView(
                                record: record,
                                onTap: {
                                    onLoadRecord(record)
                                }
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                onDeleteRecord(records[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("journal"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
