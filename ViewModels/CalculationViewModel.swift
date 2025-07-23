//
//  CalculationViewModel.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import Combine

@MainActor
class CalculationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var minutes = ""
    @Published var seconds = ""
    @Published var coefficient = "1.33"
    @Published var pushSteps = 3
    @Published var isPushMode = true
    @Published var pushResults: [(label: String, minutes: Int, seconds: Int)] = []
    @Published var showResult = false
    @Published var showSaveDialog = false
    @Published var showJournal = false
    @Published var showTimer = false
    @Published var recordName = ""
    @Published var savedRecords: [CalculationRecord] = []
    
    // Timer properties
    @Published var selectedTimerLabel = ""
    @Published var selectedTimerMinutes = 0
    @Published var selectedTimerSeconds = 0
    
    // MARK: - Computed Properties
    var isValidInput: Bool {
        guard let min = Int(minutes), min >= 0,
              let sec = Int(seconds), sec >= 0, sec < 60,
              let coeff = Double(coefficient), coeff > 0 else {
            return false
        }
        return true
    }
    
    // MARK: - Public Methods
    func calculateTime() {
        guard isValidInput else { return }
        
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
    
    func saveRecord() {
        guard !recordName.isEmpty && isValidInput else { return }
        
        guard let min = Int(minutes), min >= 0,
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
    
    func hideKeyboard() {
        // Простая реализация скрытия клавиатуры
        // В реальном приложении здесь будет более сложная логика
    }
} 