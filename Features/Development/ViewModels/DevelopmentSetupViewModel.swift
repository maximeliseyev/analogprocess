//
//  SwiftDataDevelopmentSetupViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData
import Foundation

@MainActor
class DevelopmentSetupViewModel: ObservableObject {
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
    
    func selectFilm(_ film: SwiftDataFilm) {
        print("DEBUG: selectFilm called with film: \(film.name)")
        selectedFilm = film
        iso = Int32(film.defaultISO)
        calculateTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: SwiftDataDeveloper) {
        print("DEBUG: selectDeveloper called with developer: \(developer.name)")
        selectedDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateTimeAutomatically()
    }
    
    func selectDilution(_ dilution: String) {
        selectedDilution = dilution
        calculateTimeAutomatically()
    }
    
    func selectFixer(_ fixer: SwiftDataFixer) {
        selectedFixer = fixer
    }
    
    func updateISO(_ newISO: Int) {
        iso = Int32(newISO)
        calculateTimeAutomatically()
    }
    
    func updateTemperature(_ newTemperature: Double) {
        temperature = newTemperature
        calculateTimeAutomatically()
    }
    
    func getAvailableDilutions() -> [String] {
        return getAvailableDilutionsForSwiftData()
    }
    
    func getAvailableISOs() -> [Int] {
        return getAvailableISOsForSwiftData()
    }
    
    func reloadData() {
        swiftDataService.refreshData()
        objectWillChange.send()
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
        print("DEBUG: calculateTimeAutomatically - film: \(film.name), developer: \(developer.name), dilution: \(dilutionToUse), iso: \(iso), temperature: \(temperature)")
        
        let parameters = SwiftDataDevelopmentParameters(
            film: film,
            developer: developer,
            dilution: dilutionToUse,
            temperature: temperature,
            iso: Int(iso)
        )
        
        calculatedTime = swiftDataService.calculateDevelopmentTime(parameters: parameters)
        print("DEBUG: calculateTimeAutomatically - calculated time: \(calculatedTime ?? -1)")
    }
    
    private func getAvailableDilutionsForSwiftData() -> [String] {
        guard let _ = selectedFilm,
              let developer = selectedDeveloper else {
            return []
        }
        
        // TODO: Реализовать получение доступных разведений для SwiftData
        // Пока возвращаем разведение по умолчанию
        return [developer.defaultDilution ?? ""]
    }
    
    private func getAvailableISOsForSwiftData() -> [Int] {
        guard let film = selectedFilm,
              let _ = selectedDeveloper,
              !selectedDilution.isEmpty else {
            return []
        }
        
        // TODO: Реализовать получение доступных ISO для SwiftData
        // Пока возвращаем ISO по умолчанию
        return [Int(film.defaultISO)]
    }
}
