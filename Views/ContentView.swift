//
//  ContentView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var minutes = ""
    @State private var seconds = ""
    @State private var coefficient = "1.33"
    @State private var pushSteps = 3
    @State private var isPushMode = true
    @State private var pushResults: [(label: String, minutes: Int, seconds: Int)] = []
    @State private var showResult = false
    @State private var showSaveDialog = false
    @State private var showJournal = false
    @State private var showTimer = false
    @State private var recordName = ""
    @State private var savedRecords: [CalculationRecord] = []
    
    // Для таймера
    @State private var selectedTimerLabel = ""
    @State private var selectedTimerMinutes = 0
    @State private var selectedTimerSeconds = 0
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Калькулятор")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Журнал") {
                    showJournal = true
                }
                .foregroundColor(.blue)
            }
            .padding(.top)
            
            // Form
            VStack(alignment: .leading, spacing: 15) {
                // Time Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Базовое время:")
                        .font(.headline)
                    
                    HStack {
                        TextField("Минуты", text: $minutes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("мин")
                        
                        TextField("Секунды", text: $seconds)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Text("сек")
                    }
                }
                
                // Coefficient Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Коэффициент:")
                        .font(.headline)
                    
                    HStack {
                        TextField("1.33", text: $coefficient)
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
                    
                    Picker("Тип процесса", selection: $isPushMode) {
                        Text("PULL").tag(false)
                        Text("PUSH").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Steps Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Количество ступеней:")
                        .font(.headline)
                    
                    HStack {
                        Stepper(value: $pushSteps, in: 1...5) {
                            Text("\(pushSteps)")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        Text("(от \(isPushMode ? "+" : "-")1 до \(isPushMode ? "+" : "-")\(pushSteps))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Action Buttons
            VStack(spacing: 10) {
                Button(action: calculateTime) {
                    Text("Рассчитать")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                if showResult {
                    Button(action: { showSaveDialog = true }) {
                        Text("Сохранить")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            
            // Results
            if showResult {
                CalculationResultView(
                    results: pushResults,
                    isPushMode: isPushMode,
                    onStartTimer: startTimer
                )
            }
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .sheet(isPresented: $showSaveDialog) {
            SaveRecordView(
                recordName: $recordName,
                onSave: saveRecord,
                onCancel: { showSaveDialog = false }
            )
        }
        .sheet(isPresented: $showJournal) {
            JournalView(
                records: savedRecords,
                onLoadRecord: loadRecord,
                onDeleteRecord: deleteRecord,
                onClose: { showJournal = false }
            )
        }
        .sheet(isPresented: $showTimer) {
            TimerView(
                timerLabel: selectedTimerLabel,
                totalMinutes: selectedTimerMinutes,
                totalSeconds: selectedTimerSeconds,
                onClose: { showTimer = false }
            )
        }
    }
    
    func calculateTime() {
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return
        }
        
        let calculator = DevelopmentCalculator()
        pushResults = calculator.calculateResults(
            minutes: min,
            seconds: sec,
            coefficient: coeff,
            isPushMode: isPushMode,
            steps: pushSteps
        )
        
        showResult = true
        hideKeyboard()
    }
    
    func startTimer(_ label: String, _ minutes: Int, _ seconds: Int) {
        selectedTimerLabel = label
        selectedTimerMinutes = minutes
        selectedTimerSeconds = seconds
        showTimer = true
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func saveRecord() {
        guard !recordName.isEmpty,
              let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0,
              let coeff = Double(coefficient), coeff > 0 else {
            return
        }
        
        let record = CalculationRecord(
            name: recordName,
            date: Date(),
            minutes: min,
            seconds: sec,
            coefficient: coeff,
            isPushMode: isPushMode,
            pushSteps: pushSteps
        )
        
        savedRecords.append(record)
        recordName = ""
        showSaveDialog = false
    }
    
    func loadRecord(_ record: CalculationRecord) {
        minutes = "\(record.minutes)"
        seconds = "\(record.seconds)"
        coefficient = "\(record.coefficient)"
        isPushMode = record.isPushMode
        pushSteps = record.pushSteps
        
        showJournal = false
        calculateTime()
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        savedRecords.removeAll { $0.id == record.id }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
