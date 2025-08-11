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
    @Published var iso: Int32 = Int32(Constants.ISO.defaultISO)
    @Published var dilution: String = ""
    @Published var temperature: Double = 20.0
    @Published var process: String = ""
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var comment: String = ""
    @Published var date: Date = Date()
    
    @Published var showISOPicker = false
    
    // Автодополнение
    @Published var showFilmSuggestions = false
    @Published var showDeveloperSuggestions = false
    @Published var filmSuggestions: [String] = []
    @Published var developerSuggestions: [String] = []
    
    private let swiftDataService = SwiftDataService.shared
    
    var isValid: Bool {
        !filmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !developerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Конвертация времени в секунды
    private var totalSeconds: Int {
        return minutes * 60 + seconds
    }
    
    // MARK: - Autocomplete Methods
    
    func updateFilmSuggestions() {
        let searchText = filmName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            filmSuggestions = []
            showFilmSuggestions = false
            return
        }
        
        let allFilms = swiftDataService.films
        let filteredFilms = allFilms.filter { film in
            let name = film.name
            return name.lowercased().contains(searchText)
        }
        
        filmSuggestions = filteredFilms.compactMap { $0.name }.prefix(5).map { $0 }
        showFilmSuggestions = !filmSuggestions.isEmpty
    }
    
    func updateDeveloperSuggestions() {
        let searchText = developerName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            developerSuggestions = []
            showDeveloperSuggestions = false
            return
        }
        
        let allDevelopers = swiftDataService.developers
        let filteredDevelopers = allDevelopers.filter { developer in
            let name = developer.name
            return name.lowercased().contains(searchText)
        }
        
        developerSuggestions = filteredDevelopers.compactMap { $0.name }.prefix(5).map { $0 }
        showDeveloperSuggestions = !developerSuggestions.isEmpty
    }
    
    func selectFilmSuggestion(_ filmName: String) {
        self.filmName = filmName
        showFilmSuggestions = false
        filmSuggestions = []
    }
    
    func selectDeveloperSuggestion(_ developerName: String) {
        self.developerName = developerName
        showDeveloperSuggestions = false
        developerSuggestions = []
    }
    
    func hideFilmSuggestions() {
        showFilmSuggestions = false
        filmSuggestions = []
    }
    
    func hideDeveloperSuggestions() {
        showDeveloperSuggestions = false
        developerSuggestions = []
    }
    
    func prefill(with record: JournalRecord) {
        name = record.name ?? ""
        filmName = record.filmName ?? ""
        developerName = record.developerName ?? ""
        iso = record.iso ?? Int32(Constants.ISO.defaultFilmISO)
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
        swiftDataService.saveRecord(
            filmName: filmName.trimmingCharacters(in: .whitespacesAndNewlines),
            developerName: developerName.trimmingCharacters(in: .whitespacesAndNewlines),
            dilution: dilution.trimmingCharacters(in: .whitespacesAndNewlines),
            temperature: temperature,
            iso: Int(iso),
            calculatedTime: totalSeconds,
            notes: comment.trimmingCharacters(in: .whitespacesAndNewlines)
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
        return Constants.ISO.allValues
    }
}
