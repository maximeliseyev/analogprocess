//
//  CalculatorView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("baseTime"))
                            .font(.headline)
                        
                        HStack {
                            TextField(LocalizedStringKey("minutes"), text: $viewModel.minutes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(LocalizedStringKey("min"))
                            
                            TextField(LocalizedStringKey("seconds"), text: $viewModel.seconds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(LocalizedStringKey("sec"))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("ratio"))
                            .font(.headline)
                        
                        HStack {
                            TextField("1.33", text: $viewModel.coefficient)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(LocalizedStringKey("standardRatio"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("processType"))
                            .font(.headline)
                        
                        Picker(LocalizedStringKey("processType"), selection: $viewModel.isPushMode) {
                            Text(LocalizedStringKey("pull")).tag(false)
                            Text(LocalizedStringKey("push")).tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("numberOfSteps"))
                            .font(.headline)
                        
                        HStack {
                            Stepper(value: $viewModel.pushSteps, in: 1...5) {
                                Text("\(viewModel.pushSteps)")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Text(LocalizedStringKey("from1to5"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                }
                                
                Button(action: viewModel.calculateTime) {
                    Text(LocalizedStringKey("calculateButton"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isValidInput ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.isValidInput)
                
                if viewModel.showResult {
                    Button(action: { viewModel.showSaveDialog = true }) {
                        Text(LocalizedStringKey("saveButton"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
                
                if viewModel.showResult {
                    CalculationResultView(
                        results: viewModel.pushResults,
                        isPushMode: viewModel.isPushMode,
                        onStartTimer: viewModel.startTimer
                    )
                }
                
                Spacer()
                        
            }
            .padding()
            .navigationTitle(LocalizedStringKey("calculator"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $viewModel.showSaveDialog) {
            SaveRecordView(
                recordName: $viewModel.recordName,
                onSave: viewModel.saveRecord,
                onCancel: { viewModel.showSaveDialog = false }
            )
        }
        .sheet(isPresented: $viewModel.showTimer) {
            TimerView(
                timerLabel: viewModel.selectedTimerLabel,
                totalMinutes: viewModel.selectedTimerMinutes,
                totalSeconds: viewModel.selectedTimerSeconds,
                onClose: { viewModel.showTimer = false }
            )
        }
        .onAppear {
            viewModel.loadRecords()
        }
    }
}

