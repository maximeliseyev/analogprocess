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
    
    // Для выпадающих списков
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
        selectedFilm = film
        iso = Int(film.defaultISO)
        calculateTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: Developer) {
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
        
        // Получаем доступные разбавления из Core Data
        let availableDilutions = dataService.getAvailableDilutions(for: filmId, developerId: developerId)
        
        // Если разбавлений нет, возвращаем defaultDilution проявителя
        if availableDilutions.isEmpty {
            return [developer.defaultDilution ?? ""]
        }
        
        return availableDilutions
    }
    
    // MARK: - Private Methods
    
    private func calculateTimeAutomatically() {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              !selectedDilution.isEmpty else {
            calculatedTime = nil
            return
        }
        
        let parameters = DevelopmentParameters(
            film: film,
            developer: developer,
            dilution: selectedDilution,
            temperature: temperature,
            iso: iso
        )
        
        calculatedTime = dataService.calculateDevelopmentTime(parameters: parameters)
    }
} 