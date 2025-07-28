//
//  CalculationResultView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct CalculationResultView: View {
    let results: [(label: String, minutes: Int, seconds: Int)]
    let isPushMode: Bool
    let onStartTimer: (String, Int, Int) -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            Text(LocalizedStringKey("results"))
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(results, id: \.label) { result in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.label)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)
                            
                            Text(String(format: "%d:%02d", result.minutes, result.seconds))
                                .font(.system(.title3, design: .monospaced))
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            onStartTimer(result.label, result.minutes, result.seconds)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                Text(LocalizedStringKey("timer"))
                            }
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}
