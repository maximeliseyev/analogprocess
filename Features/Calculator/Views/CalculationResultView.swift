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
    @ObservedObject var viewModel: CalculatorViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(LocalizedStringKey("results"))
                .font(.headline)
            
            VStack(spacing: 12) {
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 12) {
                            Button(action: {
                                onStartTimer(result.label, result.minutes, result.seconds)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .frame(minWidth: 80)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                viewModel.recordName = result.label
                                viewModel.showSaveDialog = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.down")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .frame(minWidth: 80)
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $viewModel.showSaveDialog) {
            SaveRecordView(
                recordName: $viewModel.recordName,
                onSave: {
                    viewModel.saveRecord()
                },
                onCancel: {
                    viewModel.showSaveDialog = false
                    viewModel.recordName = ""
                }
            )
        }
    }
}
