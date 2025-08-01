//
//  RecordRowView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import CoreData

struct RecordRowView: View {
    let record: CalculationRecord
    let onTap: () -> Void
    
    private var minutes: Int {
        Int(record.time) / 60
    }
    
    private var seconds: Int {
        Int(record.time) % 60
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: String(localized: "filmPlusDeveloper"), record.filmName ?? String(localized: "unknownFilm"), record.developerName ?? String(localized: "unknownDeveloper")))
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: String(localized: "isoLabel"), "\(record.iso)"))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Text(String(format: String(localized: "timeFormat"), "\(minutes)", String(format: "%02d", seconds), record.dilution ?? "", String(format: "%.1f", record.temperature), String(localized: "degreesCelsius")))
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
            
            if let date = record.date {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
