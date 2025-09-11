import Foundation
import SwiftData
import SwiftUI

public protocol HasStringId {
    var stringId: String { get }
}

@MainActor
public class SwiftDataRepository: ObservableObject {
    private let modelContainer: ModelContainer
    public let modelContext: ModelContext
    
    @Published var films: [SwiftDataFilm] = []
    @Published var developers: [SwiftDataDeveloper] = []
    @Published var fixers: [SwiftDataFixer] = []
    @Published var temperatureMultipliers: [SwiftDataTemperatureMultiplier] = []
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
    }
    
    // MARK: - Data Access
    func getFilm(by id: String) -> SwiftDataFilm? {
        let descriptor = FetchDescriptor<SwiftDataFilm>(
            predicate: #Predicate<SwiftDataFilm> { film in
                film.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func getDeveloper(by id: String) -> SwiftDataDeveloper? {
        let descriptor = FetchDescriptor<SwiftDataDeveloper>(
            predicate: #Predicate<SwiftDataDeveloper> { developer in
                developer.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    func getFixer(by id: String) -> SwiftDataFixer? {
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
    
    // MARK: - Development Time Queries
    func getDevelopmentTime(filmId: String, developerId: String, dilution: String, iso: Int) -> Int? {
        print("DEBUG: getDevelopmentTime - filmId: \(filmId), developerId: \(developerId), dilution: \(dilution), iso: \(iso)")

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

        let normalizedDilution = dilution.trimmingCharacters(in: .whitespacesAndNewlines)
        if let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: normalizedDilution) {
            return Int(found.time)
        }

        let lowercasedDilution = normalizedDilution.lowercased()
        if lowercasedDilution != normalizedDilution,
           let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: lowercasedDilution) {
            return Int(found.time)
        }

        if let found = fetchTime(filmId: filmId, developerId: developerId, iso: iso, dilution: nil) {
            return Int(found.time)
        }

        print("DEBUG: getDevelopmentTime - no development time found")
        return nil
    }
    
    func getTemperatureMultiplier(for temperature: Int) -> Double {
        for multiplier in temperatureMultipliers {
            if multiplier.temperature == temperature {
                return multiplier.multiplier
            }
        }
        return 1.0
    }
    
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
    
    // MARK: - Generic Sync Helper
    func syncDataGeneric<DataType, EntityType: PersistentModel>(
        _ incomingData: [String: DataType],
        createEntity: (String, DataType) -> EntityType,
        updateEntity: (EntityType, DataType) -> Bool
    ) where EntityType: Identifiable & HasStringId {
        let descriptor = FetchDescriptor<EntityType>()
        guard let existingEntities = try? modelContext.fetch(descriptor) else { return }
        
        let existingEntitiesById = Dictionary(existingEntities.map { ($0.stringId, $0) }, uniquingKeysWith: { first, _ in first })
        let incomingIds = Set(incomingData.keys)
        
        let entitiesToDelete = existingEntities.filter { !incomingIds.contains($0.stringId) }
        for entity in entitiesToDelete {
            modelContext.delete(entity)
        }
        
        for (id, data) in incomingData {
            if let existingEntity = existingEntitiesById[id] {
                _ = updateEntity(existingEntity, data)
            } else {
                let newEntity = createEntity(id, data)
                modelContext.insert(newEntity)
            }
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
    
    // MARK: - Save Context
    func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving SwiftData context: \(error)")
        }
    }
    
    // MARK: - Insert Methods for Data Loading
    func insertFilm(_ film: SwiftDataFilm) {
        modelContext.insert(film)
    }
    
    func insertDeveloper(_ developer: SwiftDataDeveloper) {
        modelContext.insert(developer)
    }
    
    func insertFixer(_ fixer: SwiftDataFixer) {
        modelContext.insert(fixer)
    }
    
    func insertDevelopmentTime(_ developmentTime: SwiftDataDevelopmentTime) {
        modelContext.insert(developmentTime)
    }
    
    func insertTemperatureMultiplier(_ multiplier: SwiftDataTemperatureMultiplier) {
        modelContext.insert(multiplier)
    }
}