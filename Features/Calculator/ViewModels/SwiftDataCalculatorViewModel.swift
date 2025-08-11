//
//  SwiftDataCalculatorViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import CoreData
import SwiftData
import Combine

@MainActor
class SwiftDataCalculatorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var minutes = ""
    @Published var seconds = ""
    @Published var coefficient = "1.33"
    @Published var pushSteps = 2
    @Published var isPushMode = true
    @Published var temperature: Double = 20.0
    @Published var pushResults: [ProcessStep] = []
    @Published var showResult = false
    @Published var showSaveDialog = false
    @Published var showTemperaturePicker = false
    @Published var showTimer = false
    
    // Core Data records
    @Published var savedRecords: [CalculationRecord] = []
    
    // SwiftData records
    @Published var savedSwiftDataRecords: [SwiftDataCalculationRecord] = []
    
    // Автодополнение для coefficient
    @Published var showCoefficientSuggestions = false
    @Published var coefficientSuggestions: [String] = []
    
    // Timer properties
    @Published var selectedTimerLabel = ""
    @Published var selectedTimerMinutes = 0
    @Published var selectedTimerSeconds = 0
    @Published var selectedResult: ProcessStep?
    
    // MARK: - Data Mode
    @Published var useSwiftData: Bool = false
    
    // MARK: - Dependencies
    private let coreDataService = CoreDataService.shared
    private let swiftDataService = SwiftDataService.shared
    private let calculator = DevelopmentCalculator()
    
    // MARK: - Computed Properties
    
    var isValidInput: Bool {
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return false
        }
        return true
    }
    
    // MARK: - Data Mode Methods
    
    func toggleDataMode() {
        useSwiftData.toggle()
        print("DEBUG: Calculator switched to \(useSwiftData ? "SwiftData" : "Core Data") mode")
        loadRecords()
    }
    
    // MARK: - Autocomplete Methods
    
    func updateCoefficientSuggestions() {
        let searchText = coefficient.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            coefficientSuggestions = []
            showCoefficientSuggestions = false
            return
        }
        
        let standardCoefficients = ["1.33", "1.25", "1.5", "1.67", "2.0", "2.5", "3.0"]
        let filteredCoefficients = standardCoefficients.filter { coeff in
            coeff.lowercased().contains(searchText)
        }
        
        coefficientSuggestions = filteredCoefficients
        showCoefficientSuggestions = !coefficientSuggestions.isEmpty
    }
    
    func selectCoefficientSuggestion(_ coefficient: String) {
        self.coefficient = coefficient
        showCoefficientSuggestions = false
        coefficientSuggestions = []
    }
    
    func hideCoefficientSuggestions() {
        showCoefficientSuggestions = false
        coefficientSuggestions = []
    }
    
    // MARK: - Calculation Methods
    
    func calculateTime() {
        guard isValidInput else { return }
        
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return
        }
        
        pushResults = calculator.calculateResults(
            minutes: min,
            seconds: sec,
            coefficient: coeff,
            isPushMode: isPushMode,
            steps: pushSteps
        )
        
        showResult = true
    }
    
    // MARK: - Timer Methods
    
    func startTimer(_ label: String, _ minutes: Int, _ seconds: Int) {
        selectedTimerLabel = label
        selectedTimerMinutes = minutes
        selectedTimerSeconds = seconds
        showResult = false // Закрываем sheet с результатами
        showTimer = true // Активируем навигацию к таймеру
    }
    
    // MARK: - Record Management Methods
    
    func saveRecord() {
        guard let selectedResult = selectedResult else { return }
        
        let totalSeconds = selectedResult.totalSeconds
        
        if useSwiftData {
            // Сохраняем в SwiftData
            saveSwiftDataRecord(selectedResult: selectedResult, totalSeconds: totalSeconds)
        } else {
            // Сохраняем в Core Data
            saveCoreDataRecord(selectedResult: selectedResult, totalSeconds: totalSeconds)
        }
        
        showSaveDialog = false
        loadRecords() // Обновляем список записей
    }
    
    private func saveCoreDataRecord(selectedResult: ProcessStep, totalSeconds: Int) {
        coreDataService.saveRecord(
            filmName: "Расчетное время",
            developerName: "Пользовательский расчет",
            dilution: "Коэффициент: \(coefficient), Температура: \(String(format: "%.1f", temperature))°C",
            iso: Constants.ISO.defaultISO,
            temperature: temperature,
            time: totalSeconds,
            name: selectedResult.label,
            comment: "Расчет: \(selectedResult.label) - \(selectedResult.formattedTime)"
        )
    }
    
    private func saveSwiftDataRecord(selectedResult: ProcessStep, totalSeconds: Int) {
        // TODO: Реализовать сохранение в SwiftData
        // Пока используем заглушку
        print("DEBUG: Saving SwiftData record - \(selectedResult.label)")
    }
    
    func loadRecords() {
        if useSwiftData {
            loadSwiftDataRecords()
        } else {
            loadCoreDataRecords()
        }
    }
    
    private func loadCoreDataRecords() {
        savedRecords = coreDataService.getCalculationRecords()
    }
    
    private func loadSwiftDataRecords() {
        // TODO: Реализовать загрузку из SwiftData
        // Пока используем заглушку
        savedSwiftDataRecords = []
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
        
        calculateTime()
    }
    
    func loadSwiftDataRecord(_ record: SwiftDataCalculationRecord) {
        let totalSeconds = Int(record.time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        self.minutes = "\(minutes)"
        self.seconds = "\(seconds)"
        coefficient = "1.33" // Используем стандартный коэффициент
        isPushMode = true
        pushSteps = 3
        
        calculateTime()
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        coreDataService.deleteCalculationRecord(record)
        loadRecords() // Обновляем список записей
    }
    
    func deleteSwiftDataRecord(_ record: SwiftDataCalculationRecord) {
        // TODO: Реализовать удаление из SwiftData
        print("DEBUG: Deleting SwiftData record - \(record.name)")
        loadRecords() // Обновляем список записей
    }
    
    func createPrefillData() -> (name: String, temperature: Double, coefficient: String, time: Int, comment: String, process: String)? {
        guard let selectedResult = selectedResult else { return nil }
        
        let totalSeconds = selectedResult.totalSeconds
        
        // Формируем строку процесса на основе настроек
        let processString = isPushMode ? "push +\(pushSteps)" : "pull -\(pushSteps)"
        
        return (
            name: selectedResult.label,
            temperature: temperature,
            coefficient: coefficient,
            time: totalSeconds,
            comment: "Расчет: \(selectedResult.label) - \(selectedResult.formattedTime)",
            process: processString
        )
    }
    
    // MARK: - Utility Methods
    
    func resetForm() {
        minutes = ""
        seconds = ""
        coefficient = "1.33"
        pushSteps = 3
        isPushMode = true
        pushResults = []
    }
}
