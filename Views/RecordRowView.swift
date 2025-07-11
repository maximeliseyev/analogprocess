//
//  RecordRowView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUICore


struct RecordRowView: View {
    let record: CalculationRecord
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(record.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(record.isPushMode ? "PUSH" : "PULL")")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(record.isPushMode ? Color.orange : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text("\(record.minutes):\(String(format: "%02d", record.seconds)) × \(String(format: "%.2f", record.coefficient))")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
            
            Text(record.date, style: .date)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
