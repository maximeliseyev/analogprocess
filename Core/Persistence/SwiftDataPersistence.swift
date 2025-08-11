//
//  SwiftDataPersistence.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftData
import SwiftUI

struct SwiftDataPersistence {
    static let shared = SwiftDataPersistence()
    
    @MainActor
    static let preview: SwiftDataPersistence = {
        let result = SwiftDataPersistence(inMemory: true)
        let modelContext = result.modelContainer.mainContext
        
        // Создаем тестовые данные для превью
        let film = SwiftDataFilm(
            id: "test-film",
            name: "Ilford HP5+",
            manufacturer: "Ilford",
            type: "Black & White",
            defaultISO: 400
        )
        
        let developer = SwiftDataDeveloper(
            id: "test-developer",
            name: "Kodak D-76",
            manufacturer: "Kodak",
            type: "powder",
            defaultDilution: "1+1"
        )
        
        let developmentTime = SwiftDataDevelopmentTime(
            dilution: "1+1",
            iso: 400,
            time: 540,
            developer: developer,
            film: film
        )
        
        modelContext.insert(film)
        modelContext.insert(developer)
        modelContext.insert(developmentTime)
        
        do {
            try modelContext.save()
        } catch {
            fatalError("Unresolved error \(error)")
        }
        return result
    }()
    
    let modelContainer: ModelContainer
    
    init(inMemory: Bool = false) {
        do {
            let schema = Schema([
                SwiftDataFilm.self,
                SwiftDataDeveloper.self,
                SwiftDataDevelopmentTime.self,
                SwiftDataFixer.self,
                SwiftDataTemperatureMultiplier.self,
                SwiftDataCalculationRecord.self
            ])
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize SwiftData: \(error)")
        }
    }
}
