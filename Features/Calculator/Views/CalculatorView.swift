//
//  CalculatorView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 15) {
                    // Time Input
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
                    
                    // Coefficient Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("ratio"))
                            .font(.headline)
                        
                        HStack {
                            TextField("1.33", text: $viewModel.coefficient)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text(LocalizedStringKey("standardCoefficient"))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Process Type
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Тип процесса:")
                            .font(.headline)
                        
                        Picker("Тип процесса", selection: $viewModel.isPushMode) {
                            Text("PULL").tag(false)
                            Text("PUSH").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if viewModel.isPushMode {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Количество шагов PUSH:")
                                .font(.headline)
                            
                            Stepper(value: $viewModel.pushSteps, in: 1...5) {
                                Text("\(viewModel.pushSteps) шагов")
                            }
                        }
                    }
                }
                                
                Button(action: viewModel.calculateTime) {
                    Text("Рассчитать")
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
                        Text("Сохранить")
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

