//
//  CoreDataService.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import CoreData
import SwiftUI

public class CoreDataService: ObservableObject {
    public static let shared = CoreDataService()
    
    let container: NSPersistentContainer
    
    @Published var films: [Film] = []
    @Published var developers: [Developer] = []
    @Published var temperatureMultipliers: [TemperatureMultiplier] = []
    
    private init() {
        container = NSPersistentContainer(name: "AnalogProcess")
        
        // Настраиваем базовые опции Core Data
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("###\(#function): Failed to retrieve a persistent store description.")
        }
        
        // Включаем базовые опции Core Data
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        loadInitialData()
    }
    
    // MARK: - Initial Data Loading
    
    private func loadInitialData() {
        let filmsCount = try? container.viewContext.count(for: Film.fetchRequest())
        let developersCount = try? container.viewContext.count(for: Developer.fetchRequest())
        
        print("DEBUG: loadInitialData - films count: \(filmsCount ?? 0), developers count: \(developersCount ?? 0)")
        
        if filmsCount == 0 || developersCount == 0 {
            print("DEBUG: loadInitialData - loading data from JSON")
            loadFilmsFromJSON()
            loadDevelopersFromJSON()
            loadDevelopmentTimesFromJSON()
            loadTemperatureMultipliersFromJSON()
            saveContext()
            refreshData()
        } else {
            print("DEBUG: loadInitialData - data already exists, refreshing")
            refreshData()
        }
    }
    
    // MARK: - JSON Loading
    
    private func loadFilmsFromJSON() {
        guard let url = Bundle.main.url(forResource: "films", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, filmData) in json {
            guard let name = filmData["name"] as? String,
                  let manufacturer = filmData["manufacturer"] as? String,
                  let type = filmData["type"] as? String,
                  let defaultISO = filmData["defaultISO"] as? Int else {
                continue
            }
            
            let film = Film(context: container.viewContext)
            film.id = id
            film.name = name
            film.manufacturer = manufacturer
            film.type = type
            film.defaultISO = Int32(defaultISO)
        }
    }
    
    private func loadDevelopersFromJSON() {
        guard let url = Bundle.main.url(forResource: "developers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
            return
        }
        
        for (id, developerData) in json {
            guard let name = developerData["name"] as? String,
                  let manufacturer = developerData["manufacturer"] as? String,
                  let type = developerData["type"] as? String,
                  let defaultDilution = developerData["defaultDilution"] as? String else {
                continue
            }
            
            let developer = Developer(context: container.viewContext)
            developer.id = id
            developer.name = name
            developer.manufacturer = manufacturer
            developer.type = type
            developer.defaultDilution = defaultDilution
        }
    }
    
    private func loadDevelopmentTimesFromJSON() {
        guard let url = Bundle.main.url(forResource: "development-times", withExtension: "json"),
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
                        
                        let developmentTime = DevelopmentTime(context: container.viewContext)
                        developmentTime.dilution = dilution
                        developmentTime.iso = Int32(iso)
                        developmentTime.time = Int32(time)
                        developmentTime.film = film
                        developmentTime.developer = developer
                    }
                }
            }
        }
    }
    
    private func loadTemperatureMultipliersFromJSON() {
        guard let url = Bundle.main.url(forResource: "temperature-multipliers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Double] else {
            return
        }
        
        for (tempString, multiplier) in json {
            guard let temperature = Int(tempString) else { continue }
            
            let tempMultiplier = TemperatureMultiplier(context: container.viewContext)
            tempMultiplier.temperature = Int32(temperature)
            tempMultiplier.multiplier = multiplier
        }
    }
    
    // MARK: - Data Access
    
    private func getFilm(by id: String) -> Film? {
        let request: NSFetchRequest<Film> = Film.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return try? container.viewContext.fetch(request).first
    }
    
    private func getDeveloper(by id: String) -> Developer? {
        let request: NSFetchRequest<Developer> = Developer.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return try? container.viewContext.fetch(request).first
    }
    
    func refreshData() {
        let filmsRequest: NSFetchRequest<Film> = Film.fetchRequest()
        filmsRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Film.name, ascending: true)]
        films = (try? container.viewContext.fetch(filmsRequest)) ?? []
        
        let developersRequest: NSFetchRequest<Developer> = Developer.fetchRequest()
        developersRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Developer.name, ascending: true)]
        developers = (try? container.viewContext.fetch(developersRequest)) ?? []
        
        let tempRequest: NSFetchRequest<TemperatureMultiplier> = TemperatureMultiplier.fetchRequest()
        tempRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TemperatureMultiplier.temperature, ascending: true)]
        temperatureMultipliers = (try? container.viewContext.fetch(tempRequest)) ?? []
    }
    
    // MARK: - Development Time Calculation
    
    func getDevelopmentTime(filmId: String, developerId: String, dilution: String, iso: Int) -> Int? {
        print("DEBUG: getDevelopmentTime - filmId: \(filmId), developerId: \(developerId), dilution: \(dilution), iso: \(iso)")
        
        let request: NSFetchRequest<DevelopmentTime> = DevelopmentTime.fetchRequest()
        request.predicate = NSPredicate(
            format: "film.id == %@ AND developer.id == %@ AND dilution == %@ AND iso == %d",
            filmId, developerId, dilution, iso
        )
        
        guard let developmentTime = try? container.viewContext.fetch(request).first else {
            print("DEBUG: getDevelopmentTime - no development time found")
            return nil
        }
        
        let time = Int(developmentTime.time)
        print("DEBUG: getDevelopmentTime - found time: \(time)")
        return time
    }
    
    func getTemperatureMultiplier(for temperature: Double) -> Double {
        let request: NSFetchRequest<TemperatureMultiplier> = TemperatureMultiplier.fetchRequest()
        request.predicate = NSPredicate(format: "temperature == %d", Int(temperature))
        
        guard let multiplier = try? container.viewContext.fetch(request).first else {
            return 1.0 // Возвращаем 1.0 если нет коэффициента
        }
        
        return multiplier.multiplier
    }
    
    /// Округляет время до ближайшей 1/4 минуты (15 секунд)
    private func roundToQuarterMinute(_ totalSeconds: Int) -> Int {
        let quarterMinuteSeconds = 15
        return Int(round(Double(totalSeconds) / Double(quarterMinuteSeconds))) * quarterMinuteSeconds
    }
    
    func calculateDevelopmentTime(parameters: DevelopmentParameters) -> Int? {
        print("DEBUG: calculateDevelopmentTime called")
        guard let baseTime = getDevelopmentTime(
            filmId: parameters.film.id ?? "",
            developerId: parameters.developer.id ?? "",
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
    
    func getAvailableDilutions(for filmId: String, developerId: String) -> [String] {
        let request: NSFetchRequest<DevelopmentTime> = DevelopmentTime.fetchRequest()
        request.predicate = NSPredicate(
            format: "film.id == %@ AND developer.id == %@",
            filmId, developerId
        )
        request.propertiesToFetch = ["dilution"]
        request.returnsDistinctResults = true
        
        let dilutions = (try? container.viewContext.fetch(request)) ?? []
        return dilutions.compactMap { $0.dilution }.sorted()
    }
    
    func getAvailableISOs(for filmId: String, developerId: String, dilution: String) -> [Int] {
        let request: NSFetchRequest<DevelopmentTime> = DevelopmentTime.fetchRequest()
        request.predicate = NSPredicate(
            format: "film.id == %@ AND developer.id == %@ AND dilution == %@",
            filmId, developerId, dilution
        )
        request.propertiesToFetch = ["iso"]
        request.returnsDistinctResults = true
        
        let isos = (try? container.viewContext.fetch(request)) ?? []
        return isos.compactMap { $0.iso }.map { Int($0) }.sorted()
    }
    
    // MARK: - Calculation Records
    
    // Унифицированный метод сохранения записи
    public func saveRecord(
        filmName: String,
        developerName: String,
        dilution: String,
        iso: Int,
        temperature: Double,
        time: Int,
        name: String? = nil,
        comment: String? = nil,
        date: Date = Date()
    ) {
        let record = CalculationRecord(context: container.viewContext)
        record.filmName = filmName
        record.developerName = developerName
        record.dilution = dilution
        record.iso = Int32(iso)
        record.temperature = temperature
        record.time = Int32(time)
        record.date = date
        record.name = name
        record.comment = comment
        
        // Устанавливаем атрибуты для CloudKit синхронизации
        record.recordID = UUID().uuidString
        record.lastModified = Date()
        record.isSynced = false
        
        saveContext()
    }
    
    // Обратная совместимость для старых методов
    @available(*, deprecated, message: "Use saveRecord instead")
    public func saveCalculationRecord(filmName: String, developerName: String, dilution: String, iso: Int, temperature: Double, time: Int, name: String? = nil, comment: String? = nil) {
        saveRecord(
            filmName: filmName,
            developerName: developerName,
            dilution: dilution,
            iso: iso,
            temperature: temperature,
            time: time,
            name: name,
            comment: comment
        )
    }
    
    @available(*, deprecated, message: "Use saveRecord instead")
    public func saveJournalRecord(_ journalRecord: JournalRecord) {
        saveRecord(
            filmName: journalRecord.filmName ?? "",
            developerName: journalRecord.developerName ?? "",
            dilution: journalRecord.dilution ?? "",
            iso: Int(journalRecord.iso ?? 100),
            temperature: journalRecord.temperature ?? 20.0,
            time: journalRecord.time ?? 0,
            name: journalRecord.name,
            comment: journalRecord.comment,
            date: journalRecord.date
        )
    }
    
    public func getCalculationRecords() -> [CalculationRecord] {
        let request: NSFetchRequest<CalculationRecord> = CalculationRecord.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CalculationRecord.date, ascending: false)]
        return (try? container.viewContext.fetch(request)) ?? []
    }
    
    public func deleteCalculationRecord(_ record: CalculationRecord) {
        container.viewContext.delete(record)
        saveContext()
    }
    
    // MARK: - Data Management
    
    func reloadDataFromJSON() {
        clearAllData()
        loadFilmsFromJSON()
        loadDevelopersFromJSON()
        loadDevelopmentTimesFromJSON()
        loadTemperatureMultipliersFromJSON()
        
        saveContext()
        refreshData()
    }
    
    func syncDataFromGitHub() async throws {
        do {
            let githubData = try await GitHubDataService.shared.downloadAllData()
            
            await MainActor.run {
            // Добавляем новые фильмы
            for (id, filmData) in githubData.films {
                if getFilm(by: id) == nil {
                    let film = Film(context: container.viewContext)
                    film.id = id
                    film.name = filmData.name
                    film.manufacturer = filmData.brand
                    film.type = filmData.type
                    film.defaultISO = Int32(filmData.iso)
                }
            }
            
            // Добавляем новых проявителей
            for (id, developerData) in githubData.developers {
                if getDeveloper(by: id) == nil {
                    let developer = Developer(context: container.viewContext)
                    developer.id = id
                    developer.name = developerData.name
                    developer.manufacturer = developerData.brand
                    developer.type = developerData.type
                    developer.defaultDilution = developerData.dilution ?? ""
                }
            }
            
            // Добавляем новые времена проявки
            for (filmId, developers) in githubData.developmentTimes {
                guard let film = getFilm(by: filmId) else { continue }
                
                for (developerId, dilutions) in developers {
                    guard let developer = getDeveloper(by: developerId) else { continue }
                    
                    for (dilution, isoTimes) in dilutions {
                        for (isoString, time) in isoTimes {
                            guard let iso = Int(isoString) else { continue }
                            
                            // Проверяем, существует ли уже такое время проявки
                            let request: NSFetchRequest<DevelopmentTime> = DevelopmentTime.fetchRequest()
                            request.predicate = NSPredicate(
                                format: "film.id == %@ AND developer.id == %@ AND dilution == %@ AND iso == %d",
                                filmId, developerId, dilution, iso
                            )
                            
                            if ((try? container.viewContext.fetch(request).first == nil) != nil) {
                                let developmentTime = DevelopmentTime(context: container.viewContext)
                                developmentTime.dilution = dilution
                                developmentTime.iso = Int32(iso)
                                developmentTime.time = Int32(time)
                                developmentTime.film = film
                                developmentTime.developer = developer
                            }
                        }
                    }
                }
            }
            
            // Добавляем новые температурные коэффициенты
            for (tempString, multiplier) in githubData.temperatureMultipliers {
                guard let temperature = Int(tempString) else { continue }
                
                let request: NSFetchRequest<TemperatureMultiplier> = TemperatureMultiplier.fetchRequest()
                request.predicate = NSPredicate(format: "temperature == %d", temperature)
                
                if ((try? container.viewContext.fetch(request).first == nil) != nil) {
                    let tempMultiplier = TemperatureMultiplier(context: container.viewContext)
                    tempMultiplier.temperature = Int32(temperature)
                    tempMultiplier.multiplier = multiplier
                }
            }
            
                saveContext()
                refreshData()
            }
        } catch {
            print("Error syncing data from GitHub: \(error)")
            throw error
        }
    }
    
    func clearAllData() {
        let entities = ["Film", "Developer", "DevelopmentTime", "TemperatureMultiplier", "CalculationRecord"]
        
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try container.viewContext.execute(deleteRequest)
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
        
        saveContext()
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
} 
