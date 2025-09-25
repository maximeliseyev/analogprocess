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
        // Используем унифицированную тестовую конфигурацию
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

        // Пытаемся инициализировать основную конфигурацию
        do {
            // Используем унифицированный менеджер конфигураций
            let (schema, modelConfiguration) = SwiftDataConfigurationManager.createPrimaryConfiguration(inMemory: inMemory)

            // Валидируем схему
            let missingEntities = SwiftDataConfigurationManager.validateSchema(schema)
            if !missingEntities.isEmpty {
                print("⚠️ Schema validation warning - missing entities: \(missingEntities)")
            }

            print("📋 Using schema v1.1 with entities: \(SwiftDataSchemas.entityNames(for: schema))")
            print(inMemory ? "🔧 Using in-memory configuration" : "☁️ Attempting CloudKit configuration...")

            self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return  // Успешная инициализация
        } catch {
            print("SwiftData CloudKit initialization failed: \(error)")

            // Детальный анализ ошибки
            if let swiftDataError = error as? SwiftDataError {
                print("SwiftData error details: \(swiftDataError)")
                print("SwiftData error localizedDescription: \(swiftDataError.localizedDescription)")
            }

            // Проверяем причину ошибки CloudKit
            if let nsError = error as NSError? {
                print("Error domain: \(nsError.domain)")
                print("Error code: \(nsError.code)")
                print("Error userInfo: \(nsError.userInfo)")
                if nsError.code == 134400 {
                    print("⚠️ CloudKit требует iCloud аккаунт. Войдите в iCloud в Настройках устройства.")
                }
            }

            // Проверяем, связана ли ошибка с моделями
            print("🔍 Проверка схемы перед fallback:")
            let currentSchema = SwiftDataSchemas.current
            for entity in currentSchema.entities {
                print("   - Entity: \(entity.name)")
            }

            // Используем стратегический fallback подход
            let recoveryStrategies: [SwiftDataRecoveryStrategy] = [
                .resetDatabase,  // Сначала пробуем сбросить базу с полной схемой
                .useMemory,      // Затем in-memory с полной схемой
                .useMinimalSchema, // Потом минимальная схема
                .useJournalOnly    // И наконец только журнал
            ]

            for strategy in recoveryStrategies {
                print("⚠️ Attempting recovery strategy: \(strategy.description)")

                do {
                    // Специальная обработка для resetDatabase
                    if strategy == .resetDatabase {
                        let url = URL.applicationSupportDirectory.appending(path: "default.store")
                        if FileManager.default.fileExists(atPath: url.path()) {
                            try FileManager.default.removeItem(at: url)
                            print("🗑️ Removed corrupted database")
                        }
                    }

                    let (schema, configuration) = SwiftDataConfigurationManager.createFallbackConfiguration(strategy: strategy)
                    let container = try ModelContainer(for: schema, configurations: [configuration])

                    print("✅ Recovery successful using \(strategy.description)")
                    print("📋 Using entities: \(SwiftDataSchemas.entityNames(for: schema))")

                    self.modelContainer = container
                    return  // Успешное восстановление

                } catch {
                    print("❌ Recovery strategy '\(strategy.description)' failed: \(error)")
                    continue
                }
            }

        // Если все стратегии восстановления провалились, создаём аварийную конфигурацию
        print("💥 All recovery strategies failed - using emergency configuration")
        let (emergencySchema, emergencyConfig) = SwiftDataConfigurationManager.createFallbackConfiguration(strategy: .useMemory)
        do {
            self.modelContainer = try ModelContainer(for: emergencySchema, configurations: [emergencyConfig])
            print("🆘 Emergency in-memory configuration successful")
        } catch {
            // Последняя попытка с минимальной схемой
            let minimalSchema = Schema([SwiftDataJournalRecord.self])
            let minimalConfig = ModelConfiguration(schema: minimalSchema, isStoredInMemoryOnly: true)
            self.modelContainer = try! ModelContainer(for: minimalSchema, configurations: [minimalConfig])
            print("🆘🆘 Ultra-minimal emergency configuration - journal only")
        }
        }
    }
}
