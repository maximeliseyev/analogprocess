//
//  CalculatorView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct CalculatorView: View {
    @StateObject private var viewModel: CalculatorViewModel
    let onStartTimer: ((String, Int, Int) -> Void)?
    
    // Управление фокусом для клавиатуры
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField: Hashable {
        case minutes
        case seconds
        case coefficient
    }
    
    init(initialTime: Int? = nil, initialTemperature: Double = 20.0, onStartTimer: ((String, Int, Int) -> Void)? = nil) {
        let vm = CalculatorViewModel()
        if let time = initialTime {
            let minutes = time / 60
            let seconds = time % 60
            vm.minutes = "\(minutes)"
            vm.seconds = "\(seconds)"
            vm.temperature = initialTemperature
        }
        _viewModel = StateObject(wrappedValue: vm)
        self.onStartTimer = onStartTimer
    }
    
    var body: some View {
        KeyboardAwareView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("baseTime"))
                            .font(.headline)
                        
                        HStack {
                            TextField(LocalizedStringKey("minutes"), text: $viewModel.minutes)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .minutes)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .seconds
                                }
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button(LocalizedStringKey("done")) {
                                            focusedField = nil
                                        }
                                    }
                                }
                            
                            Text(LocalizedStringKey("min"))
                            
                            TextField(LocalizedStringKey("seconds"), text: $viewModel.seconds)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .seconds)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .coefficient
                                }
                            
                            Text(LocalizedStringKey("sec"))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("ratio"))
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                TextField("1.33", text: $viewModel.coefficient)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .focused($focusedField, equals: .coefficient)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        focusedField = nil
                                    }
                                    .onChange(of: viewModel.coefficient) { _, _ in
                                        viewModel.updateCoefficientSuggestions()
                                    }
                                    .onTapGesture {
                                        viewModel.updateCoefficientSuggestions()
                                    }
                                    .onChange(of: focusedField) { _, newValue in
                                        if newValue != .coefficient {
                                            viewModel.hideCoefficientSuggestions()
                                        }
                                    }
                                
                                Text(LocalizedStringKey("standardRatio"))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            if viewModel.showCoefficientSuggestions {
                                AutocompleteView(
                                    suggestions: viewModel.coefficientSuggestions,
                                    onSelect: { suggestion in
                                        viewModel.selectCoefficientSuggestion(suggestion)
                                        focusedField = nil
                                    },
                                    onDismiss: {
                                        viewModel.hideCoefficientSuggestions()
                                    }
                                )
                                .zIndex(1)
                            }
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("temperature"))
                            .font(.headline)
                        
                        Button(action: {
                            focusedField = nil
                            viewModel.showTemperaturePicker = true
                        }) {
                            HStack {
                                Text(String(format: "%.1f°C", viewModel.temperature))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
                                
                Button(action: {
                    // Скрываем клавиатуру перед расчетом
                    focusedField = nil
                    viewModel.calculateTime()
                }) {
                    Text(LocalizedStringKey("calculateButton"))
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
        }
        .navigationTitle(LocalizedStringKey("calculator"))
        .navigationBarTitleDisplayMode(.inline)
        // Добавляем обработчик нажатия вне текстовых полей для скрытия клавиатуры и автодополнения
        .onTapGesture {
            focusedField = nil
            viewModel.hideCoefficientSuggestions()
        }

        .sheet(isPresented: $viewModel.showTemperaturePicker) {
            TemperaturePickerView(
                temperature: $viewModel.temperature,
                onDismiss: { viewModel.showTemperaturePicker = false }
            )
        }.sheet(isPresented: $viewModel.showResult) {
            CalculationResultView(
                results: viewModel.pushResults,
                isPushMode: viewModel.isPushMode,
                onTimerTap: { label, minutes, seconds in
                    viewModel.startTimer(label, minutes, seconds)
                    onStartTimer?(label, minutes, seconds)
                },
                viewModel: viewModel
            )
        }
        .navigationDestination(isPresented: $viewModel.showTimer) {
            TimerView(
                timerLabel: viewModel.selectedTimerLabel,
                totalMinutes: viewModel.selectedTimerMinutes,
                totalSeconds: viewModel.selectedTimerSeconds
            )
        }

        .onAppear {
            viewModel.loadRecords()
        }
    }
}

// MARK: - Preview
struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CalculatorView(onStartTimer: { label, minutes, seconds in
                print("Start timer: \(label) \(minutes):\(seconds)")
            })
        }
        .previewDisplayName("Calculator")
    }
}

