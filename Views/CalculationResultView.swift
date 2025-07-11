//
//  CalculationResultView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//


import SwiftUI

struct CalculationResultView: View {
    let results: [(label: String, minutes: Int, seconds: Int)]
    let isPushMode: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Результаты \(isPushMode ? "push" : "pull")-процесса:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(results, id: \.label) { result in
                    HStack {
                        Text(result.label)
                            .font(.system(.body, design: .monospaced))
                            .frame(width: 80, alignment: .leading)
                        
                        Text(String(format: "%d:%02d", result.minutes, result.seconds))
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
