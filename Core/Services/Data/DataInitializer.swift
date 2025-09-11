import Foundation
import SwiftData

@MainActor
public class DataInitializer {
    private let repository: SwiftDataRepository
    
    public init(repository: SwiftDataRepository) {
        self.repository = repository
    }
    
    func loadInitialData() {
        let filmsCount = repository.films.count
        let developersCount = repository.developers.count
        
        print("DEBUG: loadInitialData - films count: \(filmsCount), developers count: \(developersCount)")
        
        if filmsCount == 0 || developersCount == 0 {
            print("DEBUG: loadInitialData - loading data from JSON")
            loadFilmsFromJSON()
            loadDevelopersFromJSON()
            loadFixersFromJSON()
            loadDevelopmentTimesFromJSON()
            loadTemperatureMultipliersFromJSON()
            repository.saveContext()
            repository.refreshData()
        } else {
            print("DEBUG: loadInitialData - data already exists, refreshing")
            repository.refreshData()
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
            repository.insertFilm(film)
        }
        
        repository.saveContext()
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
            repository.insertDeveloper(developer)
        }
        
        repository.saveContext()
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
            repository.insertFixer(fixer)
        }
        
        repository.saveContext()
    }
    
    private func loadDevelopmentTimesFromJSON() {
        guard let url = Bundle.main.url(forResource: "development_times", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: [String: [String: Int]]]] else {
            return
        }
        
        for (filmId, developers) in json {
            guard let film = repository.getFilm(by: filmId) else { continue }
            
            for (developerId, dilutions) in developers {
                guard let developer = repository.getDeveloper(by: developerId) else { continue }
                
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
                        repository.insertDevelopmentTime(developmentTime)
                    }
                }
            }
        }
        
        repository.saveContext()
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
            repository.insertTemperatureMultiplier(tempMultiplier)
        }
        
        repository.saveContext()
    }
}