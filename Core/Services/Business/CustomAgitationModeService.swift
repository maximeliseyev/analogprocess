//
//  CustomAgitationModeService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import Foundation
import SwiftData


// MARK: - Custom Agitation Configuration

/// Конфигурация для создания кастомного режима агитации
public struct CustomAgitationConfig {
    public var name: String
    public var rules: [CustomAgitationRule]

    public init(name: String = "", rules: [CustomAgitationRule] = []) {
        self.name = name
        self.rules = rules
    }

    /// Создает простую конфигурацию (первая, промежуточные, последняя)
    public static func simple(
        name: String,
        firstMinute: AgitationAction,
        firstMinuteParams: [String: Int] = [:],
        intermediate: AgitationAction,
        intermediateParams: [String: Int] = [:],
        lastMinute: AgitationAction? = nil,
        lastMinuteParams: [String: Int] = [:]
    ) -> CustomAgitationConfig {
        var rules: [CustomAgitationRule] = []

        // Первая минута
        rules.append(CustomAgitationRule(
            priority: 10,
            conditionType: .firstMinute,
            conditionValues: [],
            action: firstMinute,
            parameters: firstMinuteParams
        ))

        // Последняя минута (если указана)
        if let lastAction = lastMinute {
            rules.append(CustomAgitationRule(
                priority: 10,
                conditionType: .lastMinute,
                conditionValues: [],
                action: lastAction,
                parameters: lastMinuteParams
            ))
        }

        // Промежуточные минуты (всегда в конце, чтобы приоритет был ниже)
        rules.append(CustomAgitationRule(
            priority: 1,
            conditionType: .defaultCondition,
            conditionValues: [],
            action: intermediate,
            parameters: intermediateParams
        ))

        return CustomAgitationConfig(name: name, rules: rules)
    }

    /// Валидация конфигурации
    public var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !rules.isEmpty else { return false }

        // Проверяем, что есть хотя бы одно правило по умолчанию
        let hasDefaultRule = rules.contains { $0.conditionType == .defaultCondition }
        return hasDefaultRule
    }
}

/// Конфигурация одного правила агитации
public struct CustomAgitationRule {
    public var priority: Int
    public var conditionType: AgitationRuleCondition.ConditionType
    public var conditionValues: [Int]
    public var action: AgitationAction
    public var parameters: [String: Int]

    public init(
        priority: Int,
        conditionType: AgitationRuleCondition.ConditionType,
        conditionValues: [Int],
        action: AgitationAction,
        parameters: [String: Int] = [:]
    ) {
        self.priority = priority
        self.conditionType = conditionType
        self.conditionValues = conditionValues
        self.action = action
        self.parameters = parameters
    }
}

// MARK: - Custom Agitation Mode Service

/// Сервис для работы с пользовательскими режимами ажитации
public class CustomAgitationModeService {
    private let modelContext: ModelContext?

    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    /// Получает все пользовательские режимы (отсортированы по имени)
    public func getCustomModes() -> [AgitationMode] {
        guard let modelContext = modelContext else {
            return []
        }

        do {
            let fetchDescriptor = FetchDescriptor<AgitationModeData>(
                predicate: #Predicate { $0.isCustom },
                sortBy: [SortDescriptor(\.name)]
            )
            let customModeData = try modelContext.fetch(fetchDescriptor)
            return customModeData.map { AgitationMode(from: $0) }

        } catch {
            print("❌ Failed to fetch custom agitation modes: \(error)")
            return []
        }
    }

    /// Получает конкретный пользовательский режим по имени
    public func getCustomMode(named name: String) -> AgitationMode? {
        guard let modelContext = modelContext else {
            return nil
        }

        do {
            let fetchDescriptor = FetchDescriptor<AgitationModeData>(
                predicate: #Predicate<AgitationModeData> { mode in
                    mode.isCustom && mode.name == name
                }
            )
            let modes = try modelContext.fetch(fetchDescriptor)
            return modes.first.map { AgitationMode(from: $0) }

        } catch {
            print("❌ Failed to fetch custom agitation mode '\(name)': \(error)")
            return nil
        }
    }

    /// Проверяет существование пользовательского режима с данным именем
    public func customModeExists(named name: String) -> Bool {
        return getCustomMode(named: name) != nil
    }

    /// Получает количество пользовательских режимов
    public func getCustomModeCount() -> Int {
        guard let modelContext = modelContext else {
            return 0
        }

        do {
            let fetchDescriptor = FetchDescriptor<AgitationModeData>(
                predicate: #Predicate { $0.isCustom }
            )
            return try modelContext.fetchCount(fetchDescriptor)

        } catch {
            print("❌ Failed to count custom agitation modes: \(error)")
            return 0
        }
    }

    /// Сохраняет новый пользовательский режим
    public func saveCustomMode(config: CustomAgitationConfig) throws {
        guard config.isValid else {
            throw CustomAgitationError.invalidConfiguration
        }

        guard let modelContext = modelContext else {
            throw CustomAgitationError.noModelContext
        }

        // Проверяем, что режим с таким именем не существует
        if customModeExists(named: config.name) {
            throw CustomAgitationError.modeAlreadyExists
        }

        // Преобразуем конфигурацию в business-logic правила
        let rules = config.rules.map { ruleConfig in
            AgitationRule(
                priority: ruleConfig.priority,
                condition: AgitationRuleCondition(
                    type: ruleConfig.conditionType,
                    values: ruleConfig.conditionValues
                ),
                action: ruleConfig.action,
                parameters: ruleConfig.parameters
            )
        }

        // Создаем новую SwiftData модель (нормализованная структура автоматически создаст связанные AgitationRuleData)
        let agitationModeData = AgitationModeData(
            name: config.name,
            localizedNameKey: config.name, // Для пользовательских режимов имя = ключ
            isCustom: true,
            rules: rules
        )

        modelContext.insert(agitationModeData)
        try modelContext.save()
    }

    /// Удаляет пользовательский режим
    public func deleteCustomMode(named name: String) throws {
        guard let modelContext = modelContext else {
            throw CustomAgitationError.noModelContext
        }

        let fetchDescriptor = FetchDescriptor<AgitationModeData>(
            predicate: #Predicate<AgitationModeData> { mode in
                mode.isCustom && mode.name == name
            }
        )

        let modes = try modelContext.fetch(fetchDescriptor)

        for mode in modes {
            modelContext.delete(mode)
        }

        try modelContext.save()
    }

    /// Обновляет существующий пользовательский режим
    public func updateCustomMode(oldName: String, config: CustomAgitationConfig) throws {
        guard config.isValid else {
            throw CustomAgitationError.invalidConfiguration
        }

        guard let modelContext = modelContext else {
            throw CustomAgitationError.noModelContext
        }

        // Находим существующий режим
        let fetchDescriptor = FetchDescriptor<AgitationModeData>(
            predicate: #Predicate<AgitationModeData> { mode in
                mode.isCustom && mode.name == oldName
            }
        )

        let existingModes = try modelContext.fetch(fetchDescriptor)

        if let existingMode = existingModes.first {
            // Обновляем существующий режим
            existingMode.name = config.name
            existingMode.localizedNameKey = config.name

            // Преобразуем новые правила
            let newRules = config.rules.map { ruleConfig in
                AgitationRule(
                    priority: ruleConfig.priority,
                    condition: AgitationRuleCondition(
                        type: ruleConfig.conditionType,
                        values: ruleConfig.conditionValues
                    ),
                    action: ruleConfig.action,
                    parameters: ruleConfig.parameters
                )
            }

            // Заменяем правила (SwiftData автоматически удалит старые AgitationRuleData)
            existingMode.setRules(newRules)

            try modelContext.save()
        } else {
            // Если режим не найден, создаем новый
            try saveCustomMode(config: config)
        }
    }
}

// MARK: - Errors

public enum CustomAgitationError: LocalizedError {
    case invalidConfiguration
    case noModelContext
    case modeNotFound
    case modeAlreadyExists
    case databaseError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid agitation mode configuration"
        case .noModelContext:
            return "No model context available"
        case .modeNotFound:
            return "Agitation mode not found"
        case .modeAlreadyExists:
            return "Agitation mode with this name already exists"
        case .databaseError(let error):
            return "Database error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Quick Creation Helpers

extension CustomAgitationConfig {
    /// Быстрое создание простого циклического режима
    public static func simpleCycle(
        name: String,
        agitationSeconds: Int,
        restSeconds: Int
    ) -> CustomAgitationConfig {
        return simple(
            name: name,
            firstMinute: .cycle,
            firstMinuteParams: ["agitation_seconds": agitationSeconds, "rest_seconds": restSeconds],
            intermediate: .cycle,
            intermediateParams: ["agitation_seconds": agitationSeconds, "rest_seconds": restSeconds]
        )
    }

    /// Быстрое создание режима ORWO-типа
    public static func orwoLike(
        name: String,
        firstLastAgitation: Int,
        firstLastRest: Int,
        intermediateAgitation: Int,
        intermediateRest: Int
    ) -> CustomAgitationConfig {
        return simple(
            name: name,
            firstMinute: .cycle,
            firstMinuteParams: ["agitation_seconds": firstLastAgitation, "rest_seconds": firstLastRest],
            intermediate: .cycle,
            intermediateParams: ["agitation_seconds": intermediateAgitation, "rest_seconds": intermediateRest],
            lastMinute: .cycle,
            lastMinuteParams: ["agitation_seconds": firstLastAgitation, "rest_seconds": firstLastRest]
        )
    }

    /// Быстрое создание непрерывного режима
    public static func continuous(name: String) -> CustomAgitationConfig {
        return simple(
            name: name,
            firstMinute: .continuous,
            intermediate: .continuous
        )
    }

    /// Быстрое создание режима без агитации
    public static func still(name: String) -> CustomAgitationConfig {
        return simple(
            name: name,
            firstMinute: .still,
            intermediate: .still
        )
    }
}
