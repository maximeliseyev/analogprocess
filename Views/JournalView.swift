//
//  JournalView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI


struct JournalView: View {
    let records: [CalculationRecord]
    let onLoadRecord: (CalculationRecord) -> Void
    let onDeleteRecord: (CalculationRecord) -> Void
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if records.isEmpty {
                    VStack(spacing: 20) {
                        Text("Журнал пуст")
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text("Сохраните первый расчёт, чтобы увидеть его здесь")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    List {
                        ForEach(records.sorted(by: { $0.date > $1.date }), id: \.id) { record in
                            RecordRowView(
                                record: record,
                                onTap: { onLoadRecord(record) }
                            )
                        }
                        .onDelete { indexSet in
                            let sortedRecords = records.sorted(by: { $0.date > $1.date })
                            for index in indexSet {
                                onDeleteRecord(sortedRecords[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Журнал")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        onClose()
                    }
                }
            }
        }
    }
}
