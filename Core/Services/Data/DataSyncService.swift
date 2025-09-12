import Foundation
import SwiftData

@MainActor
public class DataSyncService {
    private let repository: SwiftDataRepository
    private let githubDataService: GitHubDataService
    
    public init(repository: SwiftDataRepository, githubDataService: GitHubDataService) {
        self.repository = repository
        self.githubDataService = githubDataService
    }
    
    func syncDataFromGitHub() async throws {
        do {
            let githubData = try await githubDataService.downloadAllData()
            
            await MainActor.run {
                repository.syncDataGeneric(githubData.films, createEntity: createSwiftDataFilm, updateEntity: updateSwiftDataFilm)
                repository.syncDataGeneric(githubData.developers, createEntity: createSwiftDataDeveloper, updateEntity: updateSwiftDataDeveloper)
                repository.syncDataGeneric(githubData.fixers, createEntity: createSwiftDataFixer, updateEntity: updateSwiftDataFixer)
                syncDevelopmentTimesFromGitHub(githubData.developmentTimes)
                syncTemperatureMultipliersFromGitHub(githubData.temperatureMultipliers)
                
                repository.saveContext()
                repository.refreshData()
            }
        } catch {
            print("Error syncing data from GitHub: \(error)")
            throw error
        }
    }
    
    // MARK: - Entity Creation Helpers
    private func createSwiftDataFilm(_ id: String, _ data: GitHubFilmData) -> SwiftDataFilm {
        return SwiftDataFilm(
            id: id,
            name: data.name,
            manufacturer: data.manufacturer,
            type: data.type,
            defaultISO: Int32(data.defaultISO)
        )
    }
    
    private func createSwiftDataDeveloper(_ id: String, _ data: GitHubDeveloperData) -> SwiftDataDeveloper {
        return SwiftDataDeveloper(
            id: id,
            name: data.name,
            manufacturer: data.manufacturer,
            type: data.type,
            defaultDilution: data.defaultDilution
        )
    }
    
    private func createSwiftDataFixer(_ id: String, _ data: GitHubFixerData) -> SwiftDataFixer {
        return SwiftDataFixer(
            id: id,
            name: data.name,
            type: data.type.rawValue,
            time: data.time,
            warning: data.warning
        )
    }
    
    // MARK: - Entity Update Helpers
    private func updateSwiftDataFilm(_ entity: SwiftDataFilm, _ data: GitHubFilmData) -> Bool {
        var hasChanges = false
        if entity.name != data.name {
            entity.name = data.name
            hasChanges = true
        }
        if entity.manufacturer != data.manufacturer {
            entity.manufacturer = data.manufacturer
            hasChanges = true
        }
        if entity.type != data.type {
            entity.type = data.type
            hasChanges = true
        }
        if entity.defaultISO != Int32(data.defaultISO) {
            entity.defaultISO = Int32(data.defaultISO)
            hasChanges = true
        }
        return hasChanges
    }
    
    private func updateSwiftDataDeveloper(_ entity: SwiftDataDeveloper, _ data: GitHubDeveloperData) -> Bool {
        var hasChanges = false
        if entity.name != data.name {
            entity.name = data.name
            hasChanges = true
        }
        if entity.manufacturer != data.manufacturer {
            entity.manufacturer = data.manufacturer
            hasChanges = true
        }
        if entity.type != data.type {
            entity.type = data.type
            hasChanges = true
        }
        if entity.defaultDilution != data.defaultDilution {
            entity.defaultDilution = data.defaultDilution
            hasChanges = true
        }
        return hasChanges
    }
    
    private func updateSwiftDataFixer(_ entity: SwiftDataFixer, _ data: GitHubFixerData) -> Bool {
        var hasChanges = false
        if entity.name != data.name {
            entity.name = data.name
            hasChanges = true
        }
        if entity.type != data.type.rawValue {
            entity.type = data.type.rawValue
            hasChanges = true
        }
        if entity.time != data.time {
            entity.time = data.time
            hasChanges = true
        }
        if entity.warning != data.warning {
            entity.warning = data.warning
            hasChanges = true
        }
        return hasChanges
    }
    
    private func syncDevelopmentTimesFromGitHub(_ developmentTimes: [String: [String: [String: [String: Int]]]]) {
        func makeKey(filmId: String, developerId: String, dilution: String, iso: String) -> String {
            return "\(filmId)|\(developerId)|\(dilution)|\(iso)"
        }

        let allTimesDescriptor = FetchDescriptor<SwiftDataDevelopmentTime>()
        guard let existingTimes = try? repository.modelContext.fetch(allTimesDescriptor) else { return }
        
        let existingTimesByKey = Dictionary(existingTimes.compactMap { time -> (String, SwiftDataDevelopmentTime)? in
            guard let filmId = time.film?.id, let devId = time.developer?.id, let dilution = time.dilution else {
                return nil
            }
            let key = makeKey(filmId: filmId, developerId: devId, dilution: dilution, iso: String(time.iso))
            return (key, time)
        }, uniquingKeysWith: { (first, _) in first })

        var incomingKeys = Set<String>()

        for (filmId, developers) in developmentTimes {
            guard let film = repository.getFilm(by: filmId) else { continue }

            for (developerId, dilutions) in developers {
                guard let developer = repository.getDeveloper(by: developerId) else { continue }

                for (dilution, isoTimes) in dilutions {
                    for (isoString, time) in isoTimes {
                        guard let iso = Int32(isoString) else { continue }
                        
                        let key = makeKey(filmId: filmId, developerId: developerId, dilution: dilution, iso: isoString)
                        incomingKeys.insert(key)

                        if let existingTime = existingTimesByKey[key] {
                            if existingTime.time != Int32(time) {
                                existingTime.time = Int32(time)
                            }
                        } else {
                            let newTime = SwiftDataDevelopmentTime(
                                dilution: dilution,
                                iso: iso,
                                time: Int32(time),
                                developer: developer,
                                film: film
                            )
                            repository.insertDevelopmentTime(newTime)
                        }
                    }
                }
            }
        }
        
        let keysToDelete = Set(existingTimesByKey.keys).subtracting(incomingKeys)
        for key in keysToDelete {
            if let timeToDelete = existingTimesByKey[key] {
                repository.modelContext.delete(timeToDelete)
            }
        }
    }
    
    private func syncTemperatureMultipliersFromGitHub(_ multipliers: [String: Double]) {
        let allMultipliersDescriptor = FetchDescriptor<SwiftDataTemperatureMultiplier>()
        guard let existingMultipliers = try? repository.modelContext.fetch(allMultipliersDescriptor) else {
            return
        }
        
        let existingMultipliersByTemp = Dictionary(existingMultipliers.map { ($0.temperature, $0) }, uniquingKeysWith: { (first, _) in first })
        let incomingTemps = Set(multipliers.keys.compactMap { Int($0) })
        
        let multipliersToDelete = existingMultipliers.filter { !incomingTemps.contains($0.temperature) }
        for multiplier in multipliersToDelete {
            repository.modelContext.delete(multiplier)
        }
        
        for (tempString, multiplierValue) in multipliers {
            guard let temperature = Int(tempString) else { continue }
            
            if let existingMultiplier = existingMultipliersByTemp[temperature] {
                if existingMultiplier.multiplier != multiplierValue {
                    existingMultiplier.multiplier = multiplierValue
                }
            } else {
                let newMultiplier = SwiftDataTemperatureMultiplier(
                    temperature: temperature,
                    multiplier: multiplierValue
                )
                repository.insertTemperatureMultiplier(newMultiplier)
            }
        }
    }
}