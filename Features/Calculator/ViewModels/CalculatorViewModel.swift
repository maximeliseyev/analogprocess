//
//  SwiftDataCalculatorViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

@MainActor
class CalculatorViewModel: ObservableObject {
    // MARK: - Input Properties
    @Published var minutes = ""
    @Published var seconds = ""
    @Published var coefficient = "1.33"
    @Published var temperature: Double = 20.0
    
    // MARK: - Push Mode Properties
    @Published var isPushMode = true
    @Published var pushSteps = 3
    
    // MARK: - UI States
    @Published var showCoefficientSuggestions = false
    @Published var coefficientSuggestions: [String] = []
    @Published var showResult = false
    @Published var showTimer = false
    @Published var showSaveDialog = false
    
    // MARK: - Results
    @Published var pushResults: [ProcessStep] = []
    @Published var selectedTimerLabel = ""
    @Published var selectedTimerMinutes = 0
    @Published var selectedTimerSeconds = 0
    @Published var selectedResult: ProcessStep?
    
    // MARK: - Dependencies
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
        
        swiftDataService.saveRecord(
            filmName: "Расчетное время",
            developerName: "Пользовательский расчет",
            dilution: "Коэффициент: \(coefficient), Температура: \(String(format: "%.1f", temperature))°C",
            temperature: temperature,
            iso: Constants.ISO.defaultISO,
            calculatedTime: totalSeconds,
            notes: "Расчет: \(selectedResult.label) - \(selectedResult.formattedTime)"
        )
        
        showSaveDialog = false
    }
    
    func loadRecord(_ record: SwiftDataCalculationRecord) {
        let totalSeconds = Int(record.time)
        
        self.minutes = "\(totalSeconds / 60)"
        self.seconds = "\(totalSeconds % 60)"
        coefficient = "1.33" // Используем стандартный коэффициент
        isPushMode = true
        pushSteps = 3
        
        calculateTime()
    }
    
    func deleteRecord(_ record: SwiftDataCalculationRecord) {
        swiftDataService.deleteCalculationRecord(record)
    }
    
    func createPrefillData() -> (name: String, temperature: Double, coefficient: String, time: Int, comment: String, process: String)? {
        guard let selectedResult = selectedResult else { return nil }
        
        let totalSeconds = selectedResult.totalSeconds
        
        let name = "Расчетное время"
        let temperature = self.temperature
        let coefficient = self.coefficient
        let time = totalSeconds
        let comment = "Расчет: \(selectedResult.label) - \(selectedResult.formattedTime)"
        let process = "Пользовательский расчет"
        
        return (name, temperature, coefficient, time, comment, process)
    }
}
