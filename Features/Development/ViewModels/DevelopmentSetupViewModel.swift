//
//  SwiftDataDevelopmentSetupViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData
import Foundation

enum ProcessMode: String, CaseIterable {
    case developing = "Developing"
    case fixer = "Fixer"
}

@MainActor
class DevelopmentSetupViewModel: ObservableObject {
    // MARK: - SwiftData Properties
    @Published var selectedFilm: SwiftDataFilm?
    @Published var selectedDeveloper: SwiftDataDeveloper?
    @Published var selectedFixer: SwiftDataFixer?
    @Published var selectedDilution: String = ""
    @Published var temperature: Int = 20
    @Published var iso: Int32 = Int32(Constants.ISO.defaultISO)
    @Published var calculatedTime: Int?
    
    // MARK: - Mode Selection
    @Published var selectedMode: ProcessMode = .developing
    
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
    
    // When only a single option exists, corresponding pickers should be disabled
    var dilutionOptions: [String] {
        getAvailableDilutions()
    }
    
    var isoOptions: [Int] {
        getAvailableISOs()
    }
    
    var isDilutionSelectionLocked: Bool {
        dilutionOptions.count <= 1
    }
    
    var isISOSelectionLocked: Bool {
        isoOptions.count <= 1
    }
    
    private var temperatureOptionsCount: Int {
        let unique = Set(swiftDataService.temperatureMultipliers.map { $0.temperature })
        return unique.isEmpty ? 1 : unique.count
    }

    var isTemperatureSelectionLocked: Bool {
        // If either only one ISO option exists for the current context OR only one temperature overall
        // show the temperature row as locked (non-interactive)
        isoOptions.count <= 1 || temperatureOptionsCount <= 1
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
        calculateTimeAutomatically()
    }
    
    func updateISO(_ newISO: Int) {
        iso = Int32(newISO)
        calculateTimeAutomatically()
    }
    
    func updateTemperature(_ newTemperature: Int) {
        temperature = newTemperature
        calculateTimeAutomatically()
    }
    
    func updateMode(_ newMode: ProcessMode) {
        selectedMode = newMode
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
        switch selectedMode {
        case .developing:
            guard let film = selectedFilm,
                  let developer = selectedDeveloper else {
                calculatedTime = nil
                print("DEBUG: calculateTimeAutomatically - film or developer is nil")
                return
            }
            
            // Auto-select single available dilution/ISO when only one option exists
            let availableDilutions = getAvailableDilutionsForSwiftData()
            if availableDilutions.count == 1 {
                selectedDilution = availableDilutions[0]
            }
            let dilutionToUse = selectedDilution.isEmpty ? (developer.defaultDilution ?? "") : selectedDilution
            let availableISOs = getAvailableISOsForSwiftData()
            if availableISOs.count == 1 {
                iso = Int32(availableISOs[0])
            }
            print("DEBUG: calculateTimeAutomatically - film: \(film.name), developer: \(developer.name), dilution: \(dilutionToUse), iso: \(iso), temperature: \(temperature)")
            
            let parameters = DevelopmentParameters(
                film: film,
                developer: developer,
                dilution: dilutionToUse,
                temperature: temperature,
                iso: Int(iso)
            )
            
            calculatedTime = swiftDataService.calculateDevelopmentTime(parameters: parameters)
            print("DEBUG: calculateTimeAutomatically - calculated time: \(calculatedTime ?? -1)")
            
        case .fixer:
            guard let _ = selectedFilm,
                  let fixer = selectedFixer else {
                calculatedTime = nil
                print("DEBUG: calculateTimeAutomatically - film or fixer is nil")
                return
            }
            
            // For fixer mode, we use the fixer time directly
            calculatedTime = Int(fixer.time)
            print("DEBUG: calculateTimeAutomatically - fixer time: \(calculatedTime ?? -1)")
        }
    }
    
    private func getAvailableDilutionsForSwiftData() -> [String] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper else {
            return []
        }

        let dilutions = swiftDataService.getAvailableDilutions(filmId: film.id, developerId: developer.id)
        if dilutions.isEmpty {
            return [developer.defaultDilution ?? ""]
        }
        return dilutions
    }
    
    private func getAvailableISOsForSwiftData() -> [Int] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              !selectedDilution.isEmpty else {
            return []
        }

        let isos = swiftDataService.getAvailableISOs(filmId: film.id, developerId: developer.id, dilution: selectedDilution)
        if isos.isEmpty {
            return [Int(film.defaultISO)]
        }
        return isos
    }
}
