//
//  SwiftDataService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
public class SwiftDataService: ObservableObject, DataService {
    typealias Film = SwiftDataFilm
    typealias Developer = SwiftDataDeveloper 
    typealias Fixer = SwiftDataFixer
    private let repository: SwiftDataRepository
    private let dataInitializer: DataInitializer
    private let dataSyncService: DataSyncService
    private let developmentCalculator: DevelopmentCalculator
    
    @Published var films: [SwiftDataFilm] = []
    @Published var developers: [SwiftDataDeveloper] = []
    @Published var fixers: [SwiftDataFixer] = []
    @Published var temperatureMultipliers: [SwiftDataTemperatureMultiplier] = []
    
    public init(githubDataService: GitHubDataService, modelContainer: ModelContainer) {
        self.repository = SwiftDataRepository(modelContainer: modelContainer)
        self.dataInitializer = DataInitializer(repository: repository)
        self.dataSyncService = DataSyncService(repository: repository, githubDataService: githubDataService)
        self.developmentCalculator = DevelopmentCalculator()
        
        // Проксируем данные из репозитория
        self.films = repository.films
        self.developers = repository.developers
        self.fixers = repository.fixers
        self.temperatureMultipliers = repository.temperatureMultipliers
        
        loadInitialData()
        
        // Подписываемся на изменения в репозитории
        repository.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
            self?.films = self?.repository.films ?? []
            self?.developers = self?.repository.developers ?? []
            self?.fixers = self?.repository.fixers ?? []
            self?.temperatureMultipliers = self?.repository.temperatureMultipliers ?? []
        }.store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initial Data Loading
    func loadInitialData() {
        dataInitializer.loadInitialData()
    }
    
    
    
    func refreshData() {
        repository.refreshData()
    }
    
    
    // MARK: - Availability Queries (SwiftData)
    func getAvailableDilutions(filmId: String, developerId: String) -> [String] {
        return repository.getAvailableDilutions(filmId: filmId, developerId: developerId)
    }
    
    func getAvailableISOs(filmId: String, developerId: String, dilution: String) -> [Int] {
        return repository.getAvailableISOs(filmId: filmId, developerId: developerId, dilution: dilution)
    }

    func getAvailableDevelopers(filmId: String) -> [SwiftDataDeveloper] {
        return repository.getAvailableDevelopers(filmId: filmId)
    }
    
    
    func calculateDevelopmentTime(parameters: DevelopmentParameters) -> Int? {
        guard let baseTime = repository.getDevelopmentTime(
            filmId: parameters.film.id,
            developerId: parameters.developer.id,
            dilution: parameters.dilution,
            iso: parameters.iso
        ) else {
            return nil
        }
        
        let temperatureMultiplier = repository.getTemperatureMultiplier(for: parameters.temperature)
        let finalTime = Int(Double(baseTime) * temperatureMultiplier)
        return developmentCalculator.roundToQuarterMinute(finalTime)
    }
    
    // MARK: - GitHub Sync
    func syncDataFromGitHub() async throws {
        try await dataSyncService.syncDataFromGitHub()
    }
    
    
    
    
    
    
    
    
    // MARK: - Data Management
    func clearAllData() {
        repository.clearAllData()
    }
    
    // MARK: - Public Interface
    func getFilms() -> [SwiftDataFilm] {
        return repository.getFilms()
    }
    
    func getDevelopers() -> [SwiftDataDeveloper] {
        return repository.getDevelopers()
    }
    
    func getFixers() -> [SwiftDataFixer] {
        return repository.getFixers()
    }
    
    func getTemperatureMultipliers() -> [SwiftDataTemperatureMultiplier] {
        return repository.getTemperatureMultipliers()
    }
    
    func getTemperatureMultiplier(for temperature: Int) -> Double {
        return repository.getTemperatureMultiplier(for: temperature)
    }
    
    // MARK: - Calculation Records Management
    func saveRecord(filmName: String, developerName: String, dilution: String, temperature: Int, iso: Int, calculatedTime: Int, notes: String = "") {
        repository.saveRecord(filmName: filmName, developerName: developerName, dilution: dilution, temperature: temperature, iso: iso, calculatedTime: calculatedTime, notes: notes)
    }
    
    func getCalculationRecords() -> [SwiftDataJournalRecord] {
        return repository.getCalculationRecords()
    }
    
    func deleteCalculationRecord(_ record: SwiftDataJournalRecord) {
        repository.deleteCalculationRecord(record)
    }
    
    // MARK: - Save Context
    func saveContext() {
        repository.saveContext()
    }
}
