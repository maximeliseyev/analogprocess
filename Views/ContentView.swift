//
//  ContentView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ContentView: View {
    let initialTime: Int?
    
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
    
    // Core Data сервис
    @StateObject private var coreDataService = CoreDataService.shared
    
    init(initialTime: Int? = nil) {
        self.initialTime = initialTime
    }
    
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
                    Text("Количество шагов:")
                        .font(.headline)
                    
                    Stepper(value: $pushSteps, in: 2...10) {
                        Text("\(pushSteps) шагов")
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // Action Buttons
            HStack(spacing: 15) {
                Button("Рассчитать") {
                    calculateTime()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Таймер") {
                    showTimer = true
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadRecords()
            if let initialTime = initialTime {
                let minutes = initialTime / 60
                let seconds = initialTime % 60
                self.minutes = "\(minutes)"
                self.seconds = "\(seconds)"
            }
        }
        .sheet(isPresented: $showResult) {
            CalculationResultView(
                results: pushResults,
                isPushMode: isPushMode,
                onStartTimer: startTimer
            )
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
    
    func loadRecords() {
        savedRecords = coreDataService.getCalculationRecords()
    }
    
    func saveRecord() {
        guard !recordName.isEmpty,
              let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0,
              let coeff = Double(coefficient), coeff > 0 else {
            return
        }
        
        // Сохраняем в Core Data
        let totalTime = min * 60 + sec
        coreDataService.saveCalculationRecord(
            filmName: "Пользовательская пленка",
            developerName: "Пользовательский проявитель",
            dilution: "Пользовательское разбавление",
            iso: 400,
            temperature: 20.0,
            time: totalTime
        )
        
        recordName = ""
        showSaveDialog = false
        loadRecords() // Обновляем список записей
    }
    
    func loadRecord(_ record: CalculationRecord) {
        let totalSeconds = Int(record.time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        self.minutes = "\(minutes)"
        self.seconds = "\(seconds)"
        coefficient = "1.33" // Используем стандартный коэффициент
        isPushMode = true
        pushSteps = 3
        
        showJournal = false
        calculateTime()
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        coreDataService.deleteCalculationRecord(record)
        loadRecords() // Обновляем список записей
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
