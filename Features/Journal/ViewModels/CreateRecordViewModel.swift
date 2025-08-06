//
//  CreateRecordViewModel.swift
//  Analog Process
//
//  Created by Maxim Eliseyev on 06.08.2025.
//

import SwiftUI

@MainActor
class CreateRecordViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var filmName: String = ""
    @Published var developerName: String = ""
    @Published var iso: Int32 = 400
    @Published var dilution: String = ""
    @Published var temperature: Double = 20.0
    @Published var process: String = ""
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var comment: String = ""
    @Published var date: Date = Date()
    
    @Published var showISOPicker = false
    
    private let coreDataService = CoreDataService.shared
    
    var isValid: Bool {
        !filmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !developerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Конвертация времени в секунды
    private var totalSeconds: Int {
        return minutes * 60 + seconds
    }
    
    func prefill(with record: JournalRecord) {
        name = record.name ?? ""
        filmName = record.filmName ?? ""
        developerName = record.developerName ?? ""
        iso = record.iso ?? 100
        process = record.process ?? "push +1"
        dilution = record.dilution ?? ""
        temperature = record.temperature ?? 20.0
        
        // Конвертируем секунды обратно в минуты и секунды
        let totalSeconds = record.time ?? 0
        minutes = totalSeconds / 60
        seconds = totalSeconds % 60
        
        comment = record.comment ?? ""
        date = record.date
    }
    
    func saveRecord() {
        coreDataService.saveRecord(
            filmName: filmName.trimmingCharacters(in: .whitespacesAndNewlines),
            developerName: developerName.trimmingCharacters(in: .whitespacesAndNewlines),
            dilution: dilution.trimmingCharacters(in: .whitespacesAndNewlines),
            iso: Int(iso),
            temperature: temperature,
            time: totalSeconds,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : name.trimmingCharacters(in: .whitespacesAndNewlines),
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date
        )
    }
    
    func createJournalRecord() -> JournalRecord {
        return JournalRecord(
            date: date,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : name.trimmingCharacters(in: .whitespacesAndNewlines),
            filmName: filmName.trimmingCharacters(in: .whitespacesAndNewlines),
            developerName: developerName.trimmingCharacters(in: .whitespacesAndNewlines),
            iso: iso,
            process: process.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : process.trimmingCharacters(in: .whitespacesAndNewlines),
            dilution: dilution.trimmingCharacters(in: .whitespacesAndNewlines),
            temperature: temperature,
            time: totalSeconds,
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    
    func getAvailableISOs() -> [Int] {
        // Для журнала возвращаем все стандартные ISO значения
        return [25, 32, 40, 50, 64, 80, 100, 125, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400, 8000, 12800]
    }
}
