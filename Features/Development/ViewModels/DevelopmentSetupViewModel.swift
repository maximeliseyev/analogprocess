//
//  DevelopmentSetupViewModel.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

@MainActor
class DevelopmentSetupViewModel: ObservableObject {
    @Published var selectedFilm: Film?
    @Published var selectedDeveloper: Developer?
    @Published var selectedDilution: String = ""
    @Published var temperature: Double = 20.0
    @Published var iso: Int = 400
    @Published var calculatedTime: Int?
    @Published var showCalculator = false
    @Published var showTimer = false
    
    @Published var showFilmPicker = false
    @Published var showDeveloperPicker = false
    @Published var showDilutionPicker = false
    @Published var showISOPicker = false
    @Published var showTemperaturePicker = false
    
    private let dataService = CoreDataService.shared
    
    var films: [Film] {
        dataService.films
    }
    
    var developers: [Developer] {
        dataService.developers
    }
    
    // MARK: - Public Methods
    
    func selectFilm(_ film: Film) {
        print("DEBUG: selectFilm called with film: \(film.name ?? "")")
        selectedFilm = film
        iso = Int(film.defaultISO)
        calculateTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: Developer) {
        print("DEBUG: selectDeveloper called with developer: \(developer.name ?? "")")
        selectedDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateTimeAutomatically()
    }
    
    func selectDilution(_ dilution: String) {
        selectedDilution = dilution
        calculateTimeAutomatically()
    }
    
    func updateISO(_ newISO: Int) {
        iso = newISO
        calculateTimeAutomatically()
    }
    
    func updateTemperature(_ newTemperature: Double) {
        temperature = newTemperature
        calculateTimeAutomatically()
    }
    
    func getAvailableDilutions() -> [String] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              let filmId = film.id,
              let developerId = developer.id else {
            return []
        }
        
        let availableDilutions = dataService.getAvailableDilutions(for: filmId, developerId: developerId)
        
        if availableDilutions.isEmpty {
            return [developer.defaultDilution ?? ""]
        }
        
        return Array(Set(availableDilutions)).sorted()
    }
    
    func getAvailableISOs() -> [Int] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              let filmId = film.id,
              let developerId = developer.id,
              !selectedDilution.isEmpty else {
            return []
        }
        
        let availableISOs = dataService.getAvailableISOs(for: filmId, developerId: developerId, dilution: selectedDilution)
        
        return availableISOs
    }
    
    func reloadData() {
        dataService.reloadDataFromJSON()
        objectWillChange.send()
    }
    
    func startTimer() {
        guard calculatedTime != nil else { return }
            showTimer = true
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
            iso: iso
        )
        
        calculatedTime = dataService.calculateDevelopmentTime(parameters: parameters)
        print("DEBUG: calculateTimeAutomatically - calculated time: \(calculatedTime ?? -1)")
    }
} 
