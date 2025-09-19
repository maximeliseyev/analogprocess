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
        let film = SwiftDataFilm()
        film.id = "test-film"
        film.name = "Ilford HP5+"
        film.manufacturer = "Ilford"
        film.type = "Black & White"
        film.defaultISO = 400

        let developer = SwiftDataDeveloper()
        developer.id = "test-developer"
        developer.name = "Kodak D-76"
        developer.manufacturer = "Kodak"
        developer.type = "powder"
        developer.defaultDilution = "1+1"
        
        let developmentTime = SwiftDataDevelopmentTime()
        developmentTime.dilution = "1+1"
        developmentTime.iso = 400
        developmentTime.time = 540
        developmentTime.developer = developer
        developmentTime.film = film
        
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
        print("🚀 Starting SwiftData initialization (inMemory: \(inMemory))")

        do {
            // Начинаем с простой схемы для CloudKit
            let schema = Schema([
                SwiftDataFilm.self,
                SwiftDataDeveloper.self,
                SwiftDataJournalRecord.self,
                // AgitationModeData.self // Временно отключено для диагностики
                // TODO: Добавить остальные модели после успешного теста:
                // SwiftDataDevelopmentTime.self,
                // SwiftDataFixer.self,
                // SwiftDataTemperatureMultiplier.self,
            ])

            print("📋 Schema created with \(schema.entities.count) entities")

            let modelConfiguration: ModelConfiguration
            if inMemory {
                print("🔧 Using in-memory configuration")
                modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            } else {
                print("☁️ Attempting CloudKit configuration...")
                // Используем .private для более стабильной работы
                modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .private("iCloud.com.maximeliseyev.analogprocess")
                )
            }

            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("SwiftData CloudKit initialization failed: \(error)")
            if let swiftDataError = error as? SwiftDataError {
                print("SwiftData error details: \(swiftDataError)")
            }

            // Проверяем причину ошибки CloudKit
            if let nsError = error as NSError? {
                print("Error domain: \(nsError.domain)")
                print("Error code: \(nsError.code)")
                if nsError.code == 134400 {
                    print("⚠️ CloudKit требует iCloud аккаунт. Войдите в iCloud в Настройках устройства.")
                }
            }

            // Try fallback without CloudKit
            do {
                let fallbackSchema = Schema([
                    SwiftDataFilm.self,
                    SwiftDataDeveloper.self,
                    SwiftDataJournalRecord.self,
                    // AgitationModeData.self // Временно отключено
                ])
                let fallbackConfig = ModelConfiguration(
                    schema: fallbackSchema,
                    isStoredInMemoryOnly: false
                )
                modelContainer = try ModelContainer(for: fallbackSchema, configurations: [fallbackConfig])
                print("✅ Fallback to local storage successful")
            } catch {
                print("❌ Critical error - SwiftData initialization completely failed: \(error)")

                // Last resort: in-memory storage
                do {
                    let memorySchema = Schema([
                        SwiftDataFilm.self,
                        SwiftDataDeveloper.self,
                        SwiftDataJournalRecord.self,
                        // AgitationModeData.self // Временно отключено
                    ])
                    let memoryConfig = ModelConfiguration(schema: memorySchema, isStoredInMemoryOnly: true)
                    modelContainer = try ModelContainer(for: memorySchema, configurations: [memoryConfig])
                    print("⚠️ Using in-memory storage as last resort")
                } catch {
                    print("💥 Complete SwiftData failure: \(error)")
                    fatalError("Could not initialize SwiftData in any configuration: \(error)")
                }
            }
        }
    }
}
