//
//  SwiftDataService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
public class SwiftDataService: ObservableObject {
    public static let shared = SwiftDataService()
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    @Published var films: [SwiftDataFilm] = []
    @Published var developers: [SwiftDataDeveloper] = []
    @Published var fixers: [SwiftDataFixer] = []
    @Published var temperatureMultipliers: [SwiftDataTemperatureMultiplier] = []
    
    private init() {
        do {
            let schema = Schema([
                SwiftDataFilm.self,
                SwiftDataDeveloper.self,
                SwiftDataDevelopmentTime.self,
                SwiftDataFixer.self,
                SwiftDataTemperatureMultiplier.self,
                SwiftDataCalculationRecord.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = ModelContext(modelContainer)
            
            loadInitialData()
        } catch {
            fatalError("Could not initialize SwiftData: \(error)")
        }
    }
    
    // MARK: - Initial Data Loading
    func loadInitialData() {
        let filmsCount = try? modelContext.fetchCount(FetchDescriptor<SwiftDataFilm>())
        let developersCount = try? modelContext.fetchCount(FetchDescriptor<SwiftDataDeveloper>())
        
        print("DEBUG: loadInitialData - films count: \(filmsCount ?? 0), developers count: \(developersCount ?? 0)")
        
        if filmsCount == 0 || developersCount == 0 {
            print("DEBUG: loadInitialData - loading data from JSON")
            loadFilmsFromJSON()
            loadDevelopersFromJSON()
            loadFixersFromJSON()
            loadDevelopmentTimesFromJSON()
            loadTemperatureMultipliersFromJSON()
            saveContext()
            refreshData()
        } else {
            print("DEBUG: loadInitialData - data already exists, refreshing")
            refreshData()
        }
    }
    
    private func loadFilmsFromJSON() {
        guard let url = Bundle.main.url(forResource: "films", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, filmData) in json {
            guard let name = filmData["name"] as? String,
                  let brand = filmData["brand"] as? String,
                  let type = filmData["type"] as? String,
                  let iso = filmData["iso"] as? Int else {
                continue
            }
            
            let film = SwiftDataFilm(
                id: id,
                name: name,
                manufacturer: brand,
                type: type,
                defaultISO: Int32(iso)
            )
            modelContext.insert(film)
        }
        
        try? modelContext.save()
    }
    
    private func loadDevelopersFromJSON() {
        guard let url = Bundle.main.url(forResource: "developers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, developerData) in json {
            guard let name = developerData["name"] as? String,
                  let brand = developerData["brand"] as? String,
                  let type = developerData["type"] as? String else {
                continue
            }
            
            let developer = SwiftDataDeveloper(
                id: id,
                name: name,
                manufacturer: brand,
                type: type,
                defaultDilution: developerData["dilution"] as? String
            )
            modelContext.insert(developer)
        }
        
        try? modelContext.save()
    }
    
    private func loadFixersFromJSON() {
        guard let url = Bundle.main.url(forResource: "fixers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, fixerData) in json {
            guard let name = fixerData["name"] as? String,
                  let typeString = fixerData["type"] as? String,
                  let time = fixerData["time"] as? Int else {
                continue
            }
            
            let fixer = SwiftDataFixer(
                id: id,
                name: name,
                type: typeString,
                time: Int32(time),
                warning: fixerData["warning"] as? String
            )
            modelContext.insert(fixer)
        }
        
        try? modelContext.save()
    }
    
    private func loadDevelopmentTimesFromJSON() {
        guard let url = Bundle.main.url(forResource: "development_times", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: [String: Int]]]] else {
            return
        }
        
        for (filmId, developers) in json {
            guard let film = getFilm(by: filmId) else { continue }
            
            for (developerId, dilutions) in developers {
                guard let developer = getDeveloper(by: developerId) else { continue }
                
                for (dilution, isoTimes) in dilutions {
                    for (isoString, time) in isoTimes {
                        guard let iso = Int(isoString) else { continue }
                        
                        let developmentTime = SwiftDataDevelopmentTime(
                            dilution: dilution,
                            iso: Int32(iso),
                            time: Int32(time),
                            developer: developer,
                            film: film
                        )
                        modelContext.insert(developmentTime)
                    }
                }
            }
        }
        
        try? modelContext.save()
    }
    
    private func loadTemperatureMultipliersFromJSON() {
        guard let url = Bundle.main.url(forResource: "temperature_multipliers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Double] else {
            return
        }
        
        for (temperatureString, multiplier) in json {
            guard let temperature = Int(temperatureString) else { continue }
            
            let tempMultiplier = SwiftDataTemperatureMultiplier(
                temperature: temperature,
                multiplier: multiplier
            )
            modelContext.insert(tempMultiplier)
        }
        
        try? modelContext.save()
    }
    
    // MARK: - Data Access
    private func getFilm(by id: String) -> SwiftDataFilm? {
        let descriptor = FetchDescriptor<SwiftDataFilm>(
            predicate: #Predicate<SwiftDataFilm> { film in
                film.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    private func getDeveloper(by id: String) -> SwiftDataDeveloper? {
        let descriptor = FetchDescriptor<SwiftDataDeveloper>(
            predicate: #Predicate<SwiftDataDeveloper> { developer in
                developer.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    private func getFixer(by id: String) -> SwiftDataFixer? {
        let descriptor = FetchDescriptor<SwiftDataFixer>(
            predicate: #Predicate<SwiftDataFixer> { fixer in
                fixer.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func refreshData() {
        let filmsDescriptor = FetchDescriptor<SwiftDataFilm>(
            sortBy: [SortDescriptor(\.name)]
        )
        films = (try? modelContext.fetch(filmsDescriptor)) ?? []
        
        let developersDescriptor = FetchDescriptor<SwiftDataDeveloper>(
            sortBy: [SortDescriptor(\.name)]
        )
        developers = (try? modelContext.fetch(developersDescriptor)) ?? []
        
        let fixersDescriptor = FetchDescriptor<SwiftDataFixer>(
            sortBy: [SortDescriptor(\.name)]
        )
        fixers = (try? modelContext.fetch(fixersDescriptor)) ?? []
        
        let tempDescriptor = FetchDescriptor<SwiftDataTemperatureMultiplier>(
            sortBy: [SortDescriptor(\.temperature)]
        )
        temperatureMultipliers = (try? modelContext.fetch(tempDescriptor)) ?? []
    }
    
    // MARK: - Development Time Calculation
    func getDevelopmentTime(filmId: String, developerId: String, dilution: String, iso: Int) -> Int? {
        print("DEBUG: getDevelopmentTime - filmId: \(filmId), developerId: \(developerId), dilution: \(dilution), iso: \(iso)")

        // Helper that tries to fetch a development time with optional dilution criteria
        func fetchTime(filmId: String, developerId: String, iso: Int, dilution: String?) -> SwiftDataDevelopmentTime? {
            let iso32: Int32 = Int32(iso)
            if let dilution = dilution, !dilution.isEmpty {
                let dilutionOpt: String? = dilution
                let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
                    predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                        item.film?.id == filmId &&
                        item.developer?.id == developerId &&
                        item.iso == iso32 &&
                        item.dilution == dilutionOpt
                    }
                )
                return try? modelContext.fetch(descriptor).first
            } else {
                // No dilution specified: try to find any record that matches film+developer+iso
                let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
                    predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                        item.film?.id == filmId &&
                        item.developer?.id == developerId &&
                        item.iso == iso32
                    }
                )
                return try? modelContext.fetch(descriptor).first
            }
        }

        // Try exact match first (normalized)
        let normalizedDilution = dilution.trimmingCharacters(in: .whitespacesAndNewlines)
        if let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: normalizedDilution) {
            return Int(found.time)
        }

        // Try case-insensitive match if different
        let lowercasedDilution = normalizedDilution.lowercased()
        if lowercasedDilution != normalizedDilution,
           let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: lowercasedDilution) {
            return Int(found.time)
        }

        // Try without dilution constraint
        if let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: nil) {
            return Int(found.time)
        }

        print("DEBUG: getDevelopmentTime - no development time found")
        return nil
    }
    
    func getTemperatureMultiplier(for temperature: Int) -> Double {
        // TODO: Re-implement with proper predicate when SwiftData supports round() function
        // For now, we'll search through the array manually
        
        for multiplier in temperatureMultipliers {
            if multiplier.temperature == temperature {
                return multiplier.multiplier
            }
        }
        
        return 1.0 // Возвращаем 1.0 если нет коэффициента
    }
    
    // MARK: - Availability Queries (SwiftData)
    func getAvailableDilutions(filmId: String, developerId: String) -> [String] {
        let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
            predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                item.film?.id == filmId &&
                item.developer?.id == developerId
            }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        let dilutions = items.compactMap { ($0.dilution ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return Array(Set(dilutions)).sorted()
    }
    
    func getAvailableISOs(filmId: String, developerId: String, dilution: String) -> [Int] {
        let normalizedDilution = dilution.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<SwiftDataDevelopmentTime>(
            predicate: #Predicate<SwiftDataDevelopmentTime> { item in
                item.film?.id == filmId &&
                item.developer?.id == developerId &&
                (item.dilution ?? "") == normalizedDilution
            }
        )
        let items = (try? modelContext.fetch(descriptor)) ?? []
        let isos = items.map { Int($0.iso) }
        return Array(Set(isos)).sorted()
    }
    
    /// Округляет время до ближайшей 1/4 минуты (15 секунд)
    private func roundToQuarterMinute(_ totalSeconds: Int) -> Int {
        let quarterMinuteSeconds = 15
        return Int(round(Double(totalSeconds) / Double(quarterMinuteSeconds))) * quarterMinuteSeconds
    }
    
    func calculateDevelopmentTime(parameters: DevelopmentParameters) -> Int? {
        print("DEBUG: calculateDevelopmentTime called")
        guard let baseTime = getDevelopmentTime(
            filmId: parameters.film.id,
            developerId: parameters.developer.id,
            dilution: parameters.dilution,
            iso: parameters.iso
        ) else {
            print("DEBUG: calculateDevelopmentTime - no base time found")
            return nil
        }
        
        let temperatureMultiplier = getTemperatureMultiplier(for: parameters.temperature)
        let finalTime = Int(Double(baseTime) * temperatureMultiplier)
        let roundedTime = roundToQuarterMinute(finalTime)
        print("DEBUG: calculateDevelopmentTime - base time: \(baseTime), multiplier: \(temperatureMultiplier), final time: \(finalTime), rounded time: \(roundedTime)")
        return roundedTime
    }
    
    // MARK: - GitHub Sync
    func syncDataFromGitHub() async throws {
        do {
            let githubData = try await GitHubDataService.shared.downloadAllData()
            
            await MainActor.run {
                syncFilmsFromGitHub(githubData.films)
                syncDevelopersFromGitHub(githubData.developers)
                syncDevelopmentTimesFromGitHub(githubData.developmentTimes)
                syncTemperatureMultipliersFromGitHub(githubData.temperatureMultipliers)
                syncFixersFromGitHub(githubData.fixers)
                
                saveContext()
                refreshData()
            }
        } catch {
            print("Error syncing data from GitHub: \(error)")
            throw error
        }
    }
    
    private func syncFilmsFromGitHub(_ films: [String: GitHubFilmData]) {
        let allFilmsDescriptor = FetchDescriptor<SwiftDataFilm>()
        guard let existingFilms = try? modelContext.fetch(allFilmsDescriptor) else {
            // Handle error or return
            return
        }
        
        let existingFilmsById = Dictionary(existingFilms.map { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        let incomingFilmIds = Set(films.keys)
        
        // --- Delete films that are no longer present ---
        let filmsToDelete = existingFilms.filter { !incomingFilmIds.contains($0.id) }
        for film in filmsToDelete {
            modelContext.delete(film)
        }
        
        // --- Insert or Update films ---
        for (id, filmData) in films {
            if let existingFilm = existingFilmsById[id] {
                // Update existing film if data has changed
                if existingFilm.name != filmData.name ||
                   existingFilm.manufacturer != filmData.manufacturer ||
                   existingFilm.type != filmData.type ||
                   existingFilm.defaultISO != Int32(filmData.defaultISO) {
                    
                    existingFilm.name = filmData.name
                    existingFilm.manufacturer = filmData.manufacturer
                    existingFilm.type = filmData.type
                    existingFilm.defaultISO = Int32(filmData.defaultISO)
                }
            } else {
                // Insert new film
                let newFilm = SwiftDataFilm(
                    id: id,
                    name: filmData.name,
                    manufacturer: filmData.manufacturer,
                    type: filmData.type,
                    defaultISO: Int32(filmData.defaultISO)
                )
                modelContext.insert(newFilm)
            }
        }
    }
    
    private func syncDevelopersFromGitHub(_ developers: [String: GitHubDeveloperData]) {
        let allDevelopersDescriptor = FetchDescriptor<SwiftDataDeveloper>()
        guard let existingDevelopers = try? modelContext.fetch(allDevelopersDescriptor) else {
            return
        }
        
        let existingDevelopersById = Dictionary(existingDevelopers.map { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        let incomingDeveloperIds = Set(developers.keys)
        
        // --- Delete developers that are no longer present ---
        let developersToDelete = existingDevelopers.filter { !incomingDeveloperIds.contains($0.id) }
        for developer in developersToDelete {
            modelContext.delete(developer)
        }
        
        // --- Insert or Update developers ---
        for (id, developerData) in developers {
            if let existingDeveloper = existingDevelopersById[id] {
                // Update existing developer if data has changed
                if existingDeveloper.name != developerData.name ||
                   existingDeveloper.manufacturer != developerData.manufacturer ||
                   existingDeveloper.type != developerData.type ||
                   existingDeveloper.defaultDilution != developerData.defaultDilution {
                    
                    existingDeveloper.name = developerData.name
                    existingDeveloper.manufacturer = developerData.manufacturer
                    existingDeveloper.type = developerData.type
                    existingDeveloper.defaultDilution = developerData.defaultDilution
                }
            } else {
                // Insert new developer
                let newDeveloper = SwiftDataDeveloper(
                    id: id,
                    name: developerData.name,
                    manufacturer: developerData.manufacturer,
                    type: developerData.type,
                    defaultDilution: developerData.defaultDilution
                )
                modelContext.insert(newDeveloper)
            }
        }
    }
    
    private func syncDevelopmentTimesFromGitHub(_ developmentTimes: [String: [String: [String: [String: Int]]]]) {
        // Helper to create a unique key for a development time record
        func makeKey(filmId: String, developerId: String, dilution: String, iso: String) -> String {
            return "\(filmId)|\(developerId)|\(dilution)|\(iso)"
        }

        // 1. Fetch all existing development times and map them by a composite key
        let allTimesDescriptor = FetchDescriptor<SwiftDataDevelopmentTime>()
        guard let existingTimes = try? modelContext.fetch(allTimesDescriptor) else { return }
        
        let existingTimesByKey = Dictionary(uniqueKeysWithValues: existingTimes.compactMap { time -> (String, SwiftDataDevelopmentTime)? in
            guard let filmId = time.film?.id, let devId = time.developer?.id, let dilution = time.dilution else {
                return nil
            }
            let key = makeKey(filmId: filmId, developerId: devId, dilution: dilution, iso: String(time.iso))
            return (key, time)
        })

        var incomingKeys = Set<String>()

        // 2. Iterate through incoming data to perform inserts/updates and collect all incoming keys
        for (filmId, developers) in developmentTimes {
            guard let film = getFilm(by: filmId) else { continue }

            for (developerId, dilutions) in developers {
                guard let developer = getDeveloper(by: developerId) else { continue }

                for (dilution, isoTimes) in dilutions {
                    for (isoString, time) in isoTimes {
                        guard let iso = Int32(isoString) else { continue }
                        
                        let key = makeKey(filmId: filmId, developerId: developerId, dilution: dilution, iso: isoString)
                        incomingKeys.insert(key)

                        if let existingTime = existingTimesByKey[key] {
                            // Update if needed
                            if existingTime.time != Int32(time) {
                                existingTime.time = Int32(time)
                            }
                        } else {
                            // Insert new record
                            let newTime = SwiftDataDevelopmentTime(
                                dilution: dilution,
                                iso: iso,
                                time: Int32(time),
                                developer: developer,
                                film: film
                            )
                            modelContext.insert(newTime)
                        }
                    }
                }
            }
        }
        
        // 3. Delete records that are no longer present in the incoming data
        let keysToDelete = Set(existingTimesByKey.keys).subtracting(incomingKeys)
        for key in keysToDelete {
            if let timeToDelete = existingTimesByKey[key] {
                modelContext.delete(timeToDelete)
            }
        }
    }
    
    private func syncTemperatureMultipliersFromGitHub(_ multipliers: [String: Double]) {
        let allMultipliersDescriptor = FetchDescriptor<SwiftDataTemperatureMultiplier>()
        guard let existingMultipliers = try? modelContext.fetch(allMultipliersDescriptor) else {
            return
        }
        
        let existingMultipliersByTemp = Dictionary(existingMultipliers.map { ($0.temperature, $0) }, uniquingKeysWith: { (first, _) in first })
        let incomingTemps = Set(multipliers.keys.compactMap { Int($0) })
        
        // --- Delete multipliers that are no longer present ---
        let multipliersToDelete = existingMultipliers.filter { !incomingTemps.contains($0.temperature) }
        for multiplier in multipliersToDelete {
            modelContext.delete(multiplier)
        }
        
        // --- Insert or Update multipliers ---
        for (tempString, multiplierValue) in multipliers {
            guard let temperature = Int(tempString) else { continue }
            
            if let existingMultiplier = existingMultipliersByTemp[temperature] {
                // Update existing multiplier if value has changed
                if existingMultiplier.multiplier != multiplierValue {
                    existingMultiplier.multiplier = multiplierValue
                }
            } else {
                // Insert new multiplier
                let newMultiplier = SwiftDataTemperatureMultiplier(
                    temperature: temperature,
                    multiplier: multiplierValue
                )
                modelContext.insert(newMultiplier)
            }
        }
    }
    
    private func syncFixersFromGitHub(_ fixers: [String: GitHubFixerData]) {
        let allFixersDescriptor = FetchDescriptor<SwiftDataFixer>()
        guard let existingFixers = try? modelContext.fetch(allFixersDescriptor) else {
            return
        }
        
        let existingFixersById = Dictionary(existingFixers.map { ($0.id, $0) }, uniquingKeysWith: { (first, _) in first })
        let incomingFixerIds = Set(fixers.keys)
        
        // --- Delete fixers that are no longer present ---
        let fixersToDelete = existingFixers.filter { !incomingFixerIds.contains($0.id) }
        for fixer in fixersToDelete {
            modelContext.delete(fixer)
        }
        
        // --- Insert or Update fixers ---
        for (id, fixerData) in fixers {
            if let existingFixer = existingFixersById[id] {
                // Update existing fixer if data has changed
                if existingFixer.name != fixerData.name ||
                   existingFixer.type != fixerData.type.rawValue ||
                   existingFixer.time != Int32(fixerData.time) ||
                   existingFixer.warning != fixerData.warning {
                    
                    existingFixer.name = fixerData.name
                    existingFixer.type = fixerData.type.rawValue
                    existingFixer.time = Int32(fixerData.time)
                    existingFixer.warning = fixerData.warning
                }
            } else {
                // Insert new fixer
                let newFixer = SwiftDataFixer(
                    id: id,
                    name: fixerData.name,
                    type: fixerData.type.rawValue,
                    time: Int32(fixerData.time),
                    warning: fixerData.warning
                )
                modelContext.insert(newFixer)
            }
        }
    }
    
    // MARK: - Data Management
    func clearAllData() {
        do {
            try modelContext.delete(model: SwiftDataFilm.self)
            try modelContext.delete(model: SwiftDataDeveloper.self)
            try modelContext.delete(model: SwiftDataDevelopmentTime.self)
            try modelContext.delete(model: SwiftDataFixer.self)
            try modelContext.delete(model: SwiftDataTemperatureMultiplier.self)
            try modelContext.delete(model: SwiftDataCalculationRecord.self)
            
            saveContext()
            refreshData()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
    
    // MARK: - Public Interface
    func getFilms() -> [SwiftDataFilm] {
        return films
    }
    
    func getDevelopers() -> [SwiftDataDeveloper] {
        return developers
    }
    
    func getFixers() -> [SwiftDataFixer] {
        return fixers
    }
    
    func getTemperatureMultipliers() -> [SwiftDataTemperatureMultiplier] {
        return temperatureMultipliers
    }
    
    // MARK: - Calculation Records Management
    func saveRecord(filmName: String, developerName: String, dilution: String, temperature: Int, iso: Int, calculatedTime: Int, notes: String = "") {
        let record = SwiftDataCalculationRecord(
            comment: notes,
            date: Date(),
            developerName: developerName,
            dilution: dilution,
            filmName: filmName,
            iso: Int32(iso),
            name: "\(filmName) + \(developerName)",
            temperature: temperature,
            time: Int32(calculatedTime)
        )
        modelContext.insert(record)
        saveContext()
    }
    
    func getCalculationRecords() -> [SwiftDataCalculationRecord] {
        do {
            let descriptor = FetchDescriptor<SwiftDataCalculationRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching calculation records: \(error)")
            return []
        }
    }
    
    func deleteCalculationRecord(_ record: SwiftDataCalculationRecord) {
        modelContext.delete(record)
        saveContext()
    }
    
    // MARK: - Save Context
    func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving SwiftData context: \(error)")
        }
    }
}
