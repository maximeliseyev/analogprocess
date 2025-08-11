//
//  SwiftDataDevelopmentSetupViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

@MainActor
class SwiftDataDevelopmentSetupViewModel: ObservableObject {
    // MARK: - SwiftData Properties
    @Published var selectedFilm: SwiftDataFilm?
    @Published var selectedDeveloper: SwiftDataDeveloper?
    @Published var selectedFixer: SwiftDataFixer?
    @Published var selectedDilution: String = ""
    @Published var temperature: Double = 20.0
    @Published var iso: Int32 = Int32(Constants.ISO.defaultISO)
    @Published var calculatedTime: Int?
    
    // MARK: - UI States
    @Published var showFilmPicker = false
    @Published var showDeveloperPicker = false
    @Published var showDilutionPicker = false
    @Published var showFixerPicker = false
    @Published var showISOPicker = false
    @Published var showTemperaturePicker = false
    
    // Навигационные состояния
    @Published var navigateToCalculator = false
    @Published var navigateToTimer = false
    
    // MARK: - Services
    private let swiftDataService = SwiftDataService.shared
    
    // MARK: - Computed Properties
    
    var films: [SwiftDataFilm] {
        swiftDataService.films
    }
    
    var developers: [SwiftDataDeveloper] {
        swiftDataService.developers
    }
    
    var fixers: [SwiftDataFixer] {
        swiftDataService.fixers
    }
    
    // MARK: - Computed Properties for UI
    
    var selectedFilmName: String {
        return selectedFilm?.name ?? ""
    }
    
    var selectedDeveloperName: String {
        return selectedDeveloper?.name ?? ""
    }
    
    // MARK: - Public Methods
    
    func selectFilm(_ film: Film) {
        print("DEBUG: selectFilm called with film: \(film.name ?? "")")
        selectedFilm = film
        iso = Int32(film.defaultISO)
        calculateTimeAutomatically()
    }
    
    func selectSwiftDataFilm(_ film: SwiftDataFilm) {
        print("DEBUG: selectSwiftDataFilm called with film: \(film.name)")
        selectedSwiftDataFilm = film
        iso = Int32(film.defaultISO)
        calculateSwiftDataTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: Developer) {
        print("DEBUG: selectDeveloper called with developer: \(developer.name ?? "")")
        selectedDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateTimeAutomatically()
    }
    
    func selectSwiftDataDeveloper(_ developer: SwiftDataDeveloper) {
        print("DEBUG: selectSwiftDataDeveloper called with developer: \(developer.name)")
        selectedSwiftDataDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateSwiftDataTimeAutomatically()
    }
    
    func selectDilution(_ dilution: String) {
        selectedDilution = dilution
        if useSwiftData {
            calculateSwiftDataTimeAutomatically()
        } else {
            calculateTimeAutomatically()
        }
    }
    
    func selectFixer(_ fixer: Fixer) {
        selectedFixer = fixer
    }
    
    func selectSwiftDataFixer(_ fixer: SwiftDataFixer) {
        selectedSwiftDataFixer = fixer
    }
    
    func updateISO(_ newISO: Int) {
        iso = Int32(newISO)
        if useSwiftData {
            calculateSwiftDataTimeAutomatically()
        } else {
            calculateTimeAutomatically()
        }
    }
    
    func updateTemperature(_ newTemperature: Double) {
        temperature = newTemperature
        if useSwiftData {
            calculateSwiftDataTimeAutomatically()
        } else {
            calculateTimeAutomatically()
        }
    }
    
    func getAvailableDilutions() -> [String] {
        if useSwiftData {
            return getSwiftDataAvailableDilutions()
        } else {
            return getCoreDataAvailableDilutions()
        }
    }
    
    func getAvailableISOs() -> [Int] {
        if useSwiftData {
            return getSwiftDataAvailableISOs()
        } else {
            return getCoreDataAvailableISOs()
        }
    }
    
    func reloadData() {
        if useSwiftData {
            swiftDataService.refreshData()
        } else {
            coreDataService.reloadDataFromJSON()
        }
        objectWillChange.send()
    }
    
    func toggleDataMode() {
        useSwiftData.toggle()
        print("DEBUG: Switched to \(useSwiftData ? "SwiftData" : "Core Data") mode")
        
        // Очищаем выбранные данные при переключении
        if useSwiftData {
            selectedFilm = nil
            selectedDeveloper = nil
            selectedFixer = nil
            calculatedTime = nil
        } else {
            selectedSwiftDataFilm = nil
            selectedSwiftDataDeveloper = nil
            selectedSwiftDataFixer = nil
            calculatedSwiftDataTime = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func calculateTimeAutomatically() {
        guard let film = selectedFilm,
              let developer = selectedDeveloper else {
            calculatedTime = nil
            print("DEBUG: calculateTimeAutomatically - film or developer is nil")
            return
        }
        
        let dilutionToUse = selectedDilution.isEmpty ? (developer.defaultDilution ?? "") : selectedDilution
        print("DEBUG: calculateTimeAutomatically - film: \(film.name ?? ""), developer: \(developer.name ?? ""), dilution: \(dilutionToUse), iso: \(iso), temperature: \(temperature)")
        
        let parameters = DevelopmentParameters(
            film: film,
            developer: developer,
            dilution: dilutionToUse,
            temperature: temperature,
            iso: Int(iso)
        )
        
        calculatedTime = coreDataService.calculateDevelopmentTime(parameters: parameters)
        print("DEBUG: calculateTimeAutomatically - calculated time: \(calculatedTime ?? -1)")
    }
    
    private func calculateSwiftDataTimeAutomatically() {
        guard let film = selectedSwiftDataFilm,
              let developer = selectedSwiftDataDeveloper else {
            calculatedSwiftDataTime = nil
            print("DEBUG: calculateSwiftDataTimeAutomatically - film or developer is nil")
            return
        }
        
        let dilutionToUse = selectedDilution.isEmpty ? (developer.defaultDilution ?? "") : selectedDilution
        print("DEBUG: calculateSwiftDataTimeAutomatically - film: \(film.name), developer: \(developer.name), dilution: \(dilutionToUse), iso: \(iso), temperature: \(temperature)")
        
        let parameters = SwiftDataDevelopmentParameters(
            film: film,
            developer: developer,
            dilution: dilutionToUse,
            temperature: temperature,
            iso: Int(iso)
        )
        
        calculatedSwiftDataTime = swiftDataService.calculateDevelopmentTime(parameters: parameters)
        print("DEBUG: calculateSwiftDataTimeAutomatically - calculated time: \(calculatedSwiftDataTime ?? -1)")
    }
    
    private func getCoreDataAvailableDilutions() -> [String] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              let filmId = film.id,
              let developerId = developer.id else {
            return []
        }
        
        let availableDilutions = coreDataService.getAvailableDilutions(for: filmId, developerId: developerId)
        
        if availableDilutions.isEmpty {
            return [developer.defaultDilution ?? ""]
        }
        
        return Array(Set(availableDilutions)).sorted()
    }
    
    private func getSwiftDataAvailableDilutions() -> [String] {
        guard let film = selectedSwiftDataFilm,
              let developer = selectedSwiftDataDeveloper else {
            return []
        }
        
        // TODO: Реализовать получение доступных разведений для SwiftData
        // Пока возвращаем разведение по умолчанию
        return [developer.defaultDilution ?? ""]
    }
    
    private func getCoreDataAvailableISOs() -> [Int] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              let filmId = film.id,
              let developerId = developer.id,
              !selectedDilution.isEmpty else {
            return []
        }
        
        let availableISOs = coreDataService.getAvailableISOs(for: filmId, developerId: developerId, dilution: selectedDilution)
        
        return availableISOs
    }
    
    private func getSwiftDataAvailableISOs() -> [Int] {
        guard let film = selectedSwiftDataFilm,
              let developer = selectedSwiftDataDeveloper,
              !selectedDilution.isEmpty else {
            return []
        }
        
        // TODO: Реализовать получение доступных ISO для SwiftData
        // Пока возвращаем ISO по умолчанию
        return [Int(film.defaultISO)]
    }
}
