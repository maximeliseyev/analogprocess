//
//  CustomAgitationModeService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 18.09.2025.
//

import Foundation
import SwiftData

// MARK: - Legacy Support Types (for UI compatibility)

/// Конфигурация одной фазы агитации (legacy support)
public struct AgitationPhaseConfig {
    public enum PhaseType: String, CaseIterable, Identifiable {
        public var id: String { self.rawValue }
        case continuous = "continuous"
        case still = "still"
        case cycle = "cycle"
        case periodic = "periodic"
        case custom = "custom"

        public var localizedName: String {
            switch self {
            case .continuous:
                return String(localized: "agitationContinuous")
            case .still:
                return String(localized: "agitationStill")
            case .cycle:
                return String(localized: "agitationCycle")
            case .periodic:
                return String(localized: "agitationPeriodic")
            case .custom:
                return String(localized: "agitationCustom")
            }
        }

        public var requiresTiming: Bool {
            switch self {
            case .cycle, .periodic:
                return true
            case .continuous, .still, .custom:
                return false
            }
        }

        public var requiresCustomDescription: Bool {
            return self == .custom
        }
    }

    public var type: PhaseType
    public var agitationSeconds: Int
    public var restSeconds: Int
    public var customDescription: String?

    public init(
        type: PhaseType,
        agitationSeconds: Int = 0,
        restSeconds: Int = 0,
        customDescription: String? = nil
    ) {
        self.type = type
        self.agitationSeconds = agitationSeconds
        self.restSeconds = restSeconds
        self.customDescription = customDescription
    }
}

/// Полная конфигурация кастомного режима агитации (legacy support)
public struct CustomAgitationConfig {
    public var name: String
    public var firstMinute: AgitationPhaseConfig
    public var intermediate: AgitationPhaseConfig
    public var hasLastMinuteCustom: Bool
    public var lastMinute: AgitationPhaseConfig?

    public init(
        name: String = "",
        firstMinute: AgitationPhaseConfig = AgitationPhaseConfig(type: .continuous),
        intermediate: AgitationPhaseConfig = AgitationPhaseConfig(type: .cycle, agitationSeconds: 30, restSeconds: 30),
        hasLastMinuteCustom: Bool = false,
        lastMinute: AgitationPhaseConfig? = nil
    ) {
        self.name = name
        self.firstMinute = firstMinute
        self.intermediate = intermediate
        self.hasLastMinuteCustom = hasLastMinuteCustom
        self.lastMinute = lastMinute
    }

    /// Валидация конфигурации
    public var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }

        if firstMinute.type.requiresCustomDescription && (firstMinute.customDescription?.isEmpty ?? true) {
            return false
        }

        if intermediate.type.requiresCustomDescription && (intermediate.customDescription?.isEmpty ?? true) {
            return false
        }

        if hasLastMinuteCustom {
            guard let lastMinute = lastMinute else { return false }
            if lastMinute.type.requiresCustomDescription && (lastMinute.customDescription?.isEmpty ?? true) {
                return false
            }
        }

        return true
    }

    /// Конвертирует в новую расширенную конфигурацию
    public func toEnhanced() -> EnhancedCustomAgitationConfig {
        return EnhancedCustomAgitationConfig.fromLegacyConfig(self)
    }
}

// MARK: - Constants for UI compatibility

enum AgitationConstants {
    enum Default {
        static let agitationSeconds = 30
        static let restSeconds = 30
    }
}

// MARK: - Enhanced Custom Agitation Configuration

/// Расширенная конфигурация для создания кастомных режимов агитации
public struct EnhancedCustomAgitationConfig {
    public var name: String
    public var rules: [CustomAgitationRuleConfig]

    public init(name: String = "", rules: [CustomAgitationRuleConfig] = []) {
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
    ) -> EnhancedCustomAgitationConfig {
        var rules: [CustomAgitationRuleConfig] = []

        // Первая минута
        rules.append(CustomAgitationRuleConfig(
            priority: 10,
            conditionType: .firstMinute,
            conditionValues: [],
            action: firstMinute,
            parameters: firstMinuteParams
        ))

        // Последняя минута (если указана)
        if let lastAction = lastMinute {
            rules.append(CustomAgitationRuleConfig(
                priority: 10,
                conditionType: .lastMinute,
                conditionValues: [],
                action: lastAction,
                parameters: lastMinuteParams
            ))
        }

        // Промежуточные минуты (всегда в конце, чтобы приоритет был ниже)
        rules.append(CustomAgitationRuleConfig(
            priority: 1,
            conditionType: .defaultCondition,
            conditionValues: [],
            action: intermediate,
            parameters: intermediateParams
        ))

        return EnhancedCustomAgitationConfig(name: name, rules: rules)
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
public struct CustomAgitationRuleConfig {
    public var priority: Int
    public var conditionType: AgitationRuleCondition.ConditionType
    public var conditionValues: [Int]
    public var action: AgitationAction
    public var parameters: [String: Int]
    public var customDescription: String?

    public init(
        priority: Int,
        conditionType: AgitationRuleCondition.ConditionType,
        conditionValues: [Int],
        action: AgitationAction,
        parameters: [String: Int] = [:],
        customDescription: String? = nil
    ) {
        self.priority = priority
        self.conditionType = conditionType
        self.conditionValues = conditionValues
        self.action = action
        self.parameters = parameters
        self.customDescription = customDescription
    }
}

// MARK: - Migration Support

/// Поддержка миграции со старой системы
extension EnhancedCustomAgitationConfig {

    /// Создает конфигурацию из legacy UI-модели CustomAgitationConfig
    public static func fromLegacyConfig(_ legacy: CustomAgitationConfig) -> EnhancedCustomAgitationConfig {
        var rules: [CustomAgitationRuleConfig] = []

        // Первая минута
        let firstAction = convertPhaseTypeToAction(legacy.firstMinute.type)
        let firstParams = createParametersFromPhase(legacy.firstMinute)

        rules.append(CustomAgitationRuleConfig(
            priority: 10,
            conditionType: .firstMinute,
            conditionValues: [],
            action: firstAction,
            parameters: firstParams,
            customDescription: legacy.firstMinute.customDescription
        ))

        // Последняя минута (если есть)
        if legacy.hasLastMinuteCustom, let lastMinute = legacy.lastMinute {
            let lastAction = convertPhaseTypeToAction(lastMinute.type)
            let lastParams = createParametersFromPhase(lastMinute)

            rules.append(CustomAgitationRuleConfig(
                priority: 10,
                conditionType: .lastMinute,
                conditionValues: [],
                action: lastAction,
                parameters: lastParams,
                customDescription: lastMinute.customDescription
            ))
        }

        // Промежуточные минуты
        let intermediateAction = convertPhaseTypeToAction(legacy.intermediate.type)
        let intermediateParams = createParametersFromPhase(legacy.intermediate)

        rules.append(CustomAgitationRuleConfig(
            priority: 1,
            conditionType: .defaultCondition,
            conditionValues: [],
            action: intermediateAction,
            parameters: intermediateParams,
            customDescription: legacy.intermediate.customDescription
        ))

        return EnhancedCustomAgitationConfig(name: legacy.name, rules: rules)
    }

    private static func convertPhaseTypeToAction(_ phaseType: AgitationPhaseConfig.PhaseType) -> AgitationAction {
        switch phaseType {
        case .continuous: return .continuous
        case .still: return .still
        case .cycle: return .cycle
        case .periodic: return .periodic
        case .custom: return .rotations  // Fallback for custom
        }
    }

    private static func createParametersFromPhase(_ phase: AgitationPhaseConfig) -> [String: Int] {
        switch phase.type {
        case .cycle:
            return ["agitation_seconds": phase.agitationSeconds, "rest_seconds": phase.restSeconds]
        case .periodic:
            return ["interval_seconds": phase.agitationSeconds]
        case .continuous, .still, .custom:
            return [:]
        }
    }

}

// MARK: - Custom Agitation Mode Service

/// Сервис для работы с пользовательскими режимами агитации
public class CustomAgitationModeService {
    private let modelContext: ModelContext?

    public init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    /// Получает все пользовательские режимы
    public func getCustomModes() -> [AgitationMode] {
        guard let modelContext = modelContext else { return [] }

        do {
            // Сначала ищем новые режимы
            let newFetchDescriptor = FetchDescriptor<AgitationModeData>(
                predicate: #Predicate { $0.isCustom }
            )
            let newModes = try modelContext.fetch(newFetchDescriptor)

            // Миграция старых режимов больше не нужна, так как SwiftDataCustomAgitationMode удален

            return newModes.map { AgitationMode(from: $0) }

        } catch {
            print("Failed to fetch custom agitation modes: \(error)")
            return []
        }
    }

    /// Сохраняет новый пользовательский режим
    public func saveCustomMode(config: EnhancedCustomAgitationConfig, migrate: Bool = false) throws -> AgitationMode {
        guard config.isValid else {
            throw CustomAgitationError.invalidConfiguration
        }

        guard let modelContext = modelContext else {
            throw CustomAgitationError.noModelContext
        }

        // Преобразуем конфигурацию в правила
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

        // Создаем новую модель данных
        let agitationModeData = AgitationModeData(
            name: config.name,
            localizedNameKey: config.name, // Для пользовательских режимов имя = ключ
            isCustom: true,
            rules: rules
        )

        modelContext.insert(agitationModeData)

        if !migrate {
            try modelContext.save()
        }

        return AgitationMode(from: agitationModeData)
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
    public func updateCustomMode(oldName: String, config: EnhancedCustomAgitationConfig) throws -> AgitationMode {
        guard config.isValid else {
            throw CustomAgitationError.invalidConfiguration
        }

        // Удаляем старый режим
        try deleteCustomMode(named: oldName)

        // Создаем новый
        return try saveCustomMode(config: config)
    }
}

// MARK: - Errors

public enum CustomAgitationError: LocalizedError {
    case invalidConfiguration
    case noModelContext
    case modeNotFound

    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid agitation mode configuration"
        case .noModelContext:
            return "No model context available"
        case .modeNotFound:
            return "Agitation mode not found"
        }
    }
}

// MARK: - Quick Creation Helpers

extension EnhancedCustomAgitationConfig {
    /// Быстрое создание простого циклического режима
    public static func simpleCycle(
        name: String,
        agitationSeconds: Int,
        restSeconds: Int
    ) -> EnhancedCustomAgitationConfig {
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
    ) -> EnhancedCustomAgitationConfig {
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
}
