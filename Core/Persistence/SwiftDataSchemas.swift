//
//  SwiftDataSchemas.swift
//  AnalogProcess
//
//  Created for schema versioning and migration management
//

import SwiftData
import Foundation

/// Управление версиями схем SwiftData
enum SwiftDataSchemas {

    /// Версия 1.0 - базовая схема без AgitationModeData
    static var v1_0: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
        ])
    }

    /// Версия 1.1 - добавлена поддержка кастомных режимов агитации
    static var v1_1: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
        ])
    }

    /// Версия 1.3 - нормализованная структура для AgitationModeData с отдельной таблицей правил
    static var v1_3: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            AgitationRuleData.self,
        ])
    }

    /// Версия 1.2 - полная схема со всеми моделями
    static var v1_2: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            SwiftDataDevelopmentTime.self,
            SwiftDataFixer.self,
            SwiftDataTemperatureMultiplier.self,
        ])
    }

    /// Версия 1.4 - полная схема с нормализованными агитационными правилами
    static var v1_4: Schema {
        Schema([
            SwiftDataFilm.self,
            SwiftDataDeveloper.self,
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            AgitationRuleData.self,
            SwiftDataDevelopmentTime.self,
            SwiftDataFixer.self,
            SwiftDataTemperatureMultiplier.self,
        ])
    }

    /// Текущая активная схема - используем v1.3 с нормализованной структурой агитации
    static var current: Schema {
        return v1_3 // Переходим на нормализованную схему
    }

    /// Минимальная схема для критических ситуаций
    static var minimal: Schema {
        Schema([
            SwiftDataJournalRecord.self,
            AgitationModeData.self,
            AgitationRuleData.self,
        ])
    }

    /// Абсолютно базовая схема только с журналом
    static var journalOnly: Schema {
        Schema([
            SwiftDataJournalRecord.self,
        ])
    }

    /// Получить список всех сущностей в строковом виде для логирования
    static func entityNames(for schema: Schema) -> [String] {
        return schema.entities.map { $0.name }
    }
}

/// Стратегии восстановления при ошибках схемы
enum SwiftDataRecoveryStrategy: CaseIterable {
    case useMemory
    case resetDatabase
    case useMinimalSchema
    case useJournalOnly
    case fatal

    var description: String {
        switch self {
        case .useMemory:
            return "Переключение на in-memory хранилище"
        case .resetDatabase:
            return "Сброс базы данных и создание новой"
        case .useMinimalSchema:
            return "Использование минимальной схемы"
        case .useJournalOnly:
            return "Использование только журнала"
        case .fatal:
            return "Критическая ошибка"
        }
    }

    var schema: Schema {
        switch self {
        case .useMemory, .resetDatabase:
            return SwiftDataSchemas.current
        case .useMinimalSchema:
            return SwiftDataSchemas.minimal
        case .useJournalOnly:
            return SwiftDataSchemas.journalOnly
        case .fatal:
            return SwiftDataSchemas.journalOnly // Fallback, хотя не должно использоваться
        }
    }

    var isInMemory: Bool {
        switch self {
        case .useMemory:
            return true
        default:
            return false
        }
    }
}

/// Менеджер для унифицированного создания SwiftData конфигураций
struct SwiftDataConfigurationManager {

    /// Создаёт основную конфигурацию для CloudKit или локального хранения
    static func createPrimaryConfiguration(inMemory: Bool = false) -> (Schema, ModelConfiguration) {
        let schema = SwiftDataSchemas.current

        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            // Пробуем CloudKit конфигурацию
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.maximeliseyev.analogprocess")
            )
        }

        return (schema, configuration)
    }

    /// Создаёт fallback конфигурацию для восстановления
    static func createFallbackConfiguration(strategy: SwiftDataRecoveryStrategy) -> (Schema, ModelConfiguration) {
        let schema = strategy.schema

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: strategy.isInMemory
        )

        return (schema, configuration)
    }

    /// Создаёт тестовую конфигурацию (всегда in-memory)
    static func createTestConfiguration() -> (Schema, ModelConfiguration) {
        let schema = SwiftDataSchemas.minimal // Используем минимальную схему для тестов

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return (schema, configuration)
    }

    /// Валидирует схему на полноту
    static func validateSchema(_ schema: Schema) -> [String] {
        var missingEntities: [String] = []

        let expectedEntities = [
            "SwiftDataFilm",
            "SwiftDataDeveloper",
            "SwiftDataJournalRecord",
            "AgitationModeData",
            "AgitationRuleData"
        ]

        let currentEntities = schema.entities.map { $0.name }

        for expected in expectedEntities {
            if !currentEntities.contains(expected) {
                missingEntities.append(expected)
            }
        }

        return missingEntities
    }

    /// Более детальная валидация схемы с предупреждениями
    static func performDetailedValidation(_ schema: Schema) -> SchemaValidationResult {
        var warnings: [String] = []
        var errors: [String] = []

        let expectedEntities = [
            "SwiftDataFilm",
            "SwiftDataDeveloper",
            "SwiftDataJournalRecord",
            "AgitationModeData",
            "AgitationRuleData",
            "SwiftDataDevelopmentTime",
            "SwiftDataFixer",
            "SwiftDataTemperatureMultiplier"
        ]

        let currentEntities = schema.entities.map { $0.name }

        // Проверяем критически важные сущности
        let criticalEntities = ["SwiftDataJournalRecord"]
        for critical in criticalEntities {
            if !currentEntities.contains(critical) {
                errors.append("Missing critical entity: \(critical)")
            }
        }

        // Проверяем желательные сущности
        let optionalEntities = expectedEntities.filter { !criticalEntities.contains($0) }
        for optional in optionalEntities {
            if !currentEntities.contains(optional) {
                warnings.append("Missing optional entity: \(optional)")
            }
        }

        // Проверяем неожиданные сущности
        for current in currentEntities {
            if !expectedEntities.contains(current) {
                warnings.append("Unexpected entity found: \(current)")
            }
        }

        return SchemaValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            entityCount: currentEntities.count
        )
    }

    /// Сравнивает две схемы на совместимость
    static func compareSchemas(_ schema1: Schema, _ schema2: Schema) -> SchemaCompatibilityResult {
        let entities1 = Set(schema1.entities.map { $0.name })
        let entities2 = Set(schema2.entities.map { $0.name })

        let added = entities2.subtracting(entities1)
        let removed = entities1.subtracting(entities2)
        let common = entities1.intersection(entities2)

        let isCompatible = removed.isEmpty // Схемы совместимы если ничего не удалено

        return SchemaCompatibilityResult(
            isCompatible: isCompatible,
            addedEntities: Array(added),
            removedEntities: Array(removed),
            commonEntities: Array(common)
        )
    }
}

/// Результат валидации схемы
struct SchemaValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    let entityCount: Int

    var hasWarnings: Bool { !warnings.isEmpty }
    var hasErrors: Bool { !errors.isEmpty }
}

/// Результат сравнения схем
struct SchemaCompatibilityResult {
    let isCompatible: Bool
    let addedEntities: [String]
    let removedEntities: [String]
    let commonEntities: [String]

    var hasMigration: Bool { !addedEntities.isEmpty || !removedEntities.isEmpty }
}

