//
//  CalculatorViewModel.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class CalculatorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var minutes = ""
    @Published var seconds = ""
    @Published var coefficient = "1.33"
    @Published var pushSteps = 5
    @Published var isPushMode = true
    @Published var temperature: Double = 20.0
    @Published var pushResults: [(label: String, minutes: Int, seconds: Int)] = []
    @Published var showResult = false
    @Published var showSaveDialog = false
    @Published var showTimer = false
    @Published var showTemperaturePicker = false
    @Published var savedRecords: [CalculationRecord] = []
    
    // Timer properties
    @Published var selectedTimerLabel = ""
    @Published var selectedTimerMinutes = 0
    @Published var selectedTimerSeconds = 0
    @Published var selectedResult: (label: String, minutes: Int, seconds: Int)?
    
    // MARK: - Dependencies
    private let coreDataService = CoreDataService.shared
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
        showTimer = true
    }
    
    // MARK: - Record Management Methods
    
    func saveRecord() {
        guard let selectedResult = selectedResult else { return }
        
        let totalSeconds = selectedResult.minutes * 60 + selectedResult.seconds
        
        // Сохраняем в Core Data с информацией о расчете
        coreDataService.saveRecord(
            filmName: "Расчетное время",
            developerName: "Пользовательский расчет",
            dilution: "Коэффициент: \(coefficient), Температура: \(String(format: "%.1f", temperature))°C",
            iso: 400,
            temperature: temperature,
            time: totalSeconds,
            name: selectedResult.label,
            comment: "Расчет: \(selectedResult.label) - \(selectedResult.minutes):\(String(format: "%02d", selectedResult.seconds))"
        )
        
        showSaveDialog = false
        loadRecords() // Обновляем список записей
    }
    
    func loadRecords() {
        savedRecords = coreDataService.getCalculationRecords()
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
    
    func deleteRecord(_ record: CalculationRecord) {
        coreDataService.deleteCalculationRecord(record)
        loadRecords() // Обновляем список записей
    }
    

    
    func createPrefillData() -> JournalRecord? {
        guard let selectedResult = selectedResult else { return nil }
        
        let totalSeconds = selectedResult.minutes * 60 + selectedResult.seconds
        
        return JournalRecord(
            date: Date(),
            name: selectedResult.label,
            filmName: "Расчетное время",
            developerName: "Пользовательский расчет",
            process: "Расчет",
            dilution: "Коэффициент: \(coefficient), Температура: \(String(format: "%.1f", temperature))°C",
            temperature: temperature,
            time: totalSeconds,
            comment: "Расчет: \(selectedResult.label) - \(selectedResult.minutes):\(String(format: "%02d", selectedResult.seconds))"
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
