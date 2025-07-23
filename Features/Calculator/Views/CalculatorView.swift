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
                // Header
                HStack {
                    Text("Калькулятор времени")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.top)
                
                // Form
                VStack(alignment: .leading, spacing: 15) {
                    // Time Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Базовое время:")
                            .font(.headline)
                        
                        HStack {
                            TextField("Минуты", text: $viewModel.minutes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("мин")
                            
                            TextField("Секунды", text: $viewModel.seconds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("сек")
                        }
                    }
                    
                    // Coefficient Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Коэффициент:")
                            .font(.headline)
                        
                        HStack {
                            TextField("1.33", text: $viewModel.coefficient)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("(стандартный 1.33)")
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
                    
                    // Push Steps (только для PUSH)
                    if viewModel.isPushMode {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Количество шагов PUSH:")
                                .font(.headline)
                            
                            Stepper(value: $viewModel.pushSteps, in: 1...10) {
                                Text("\(viewModel.pushSteps) шагов")
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Calculate Button
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
            }
            .padding()
            .navigationTitle("Калькулятор")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $viewModel.showResult) {
            CalculationResultView(
                results: viewModel.pushResults,
                isPushMode: viewModel.isPushMode,
                onStartTimer: viewModel.startTimer
            )
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

