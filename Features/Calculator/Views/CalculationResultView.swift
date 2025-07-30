//
//  CalculationResultView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import CoreData

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
                                .monospacedBodyStyle()
                            
                            Text(String(format: "%d:%02d", result.minutes, result.seconds))
                                .monospacedTitleStyle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 12) {
                            Button(action: {
                                onStartTimer(result.label, result.minutes, result.seconds)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                        .iconButtonStyle()
                                }
                                .primaryButtonStyle()
                            }
                            
                            Button(action: {
                                viewModel.recordName = result.label
                                viewModel.showSaveDialog = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "square.and.arrow.down")
                                        .iconButtonStyle()
                                }
                                .secondaryButtonStyle()
                            }
                        }
                    }
                    .cardStyle()
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
