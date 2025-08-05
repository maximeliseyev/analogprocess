//
//  AgitationMode.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 23.07.2025.
//

import Foundation

// MARK: - Protocols

/// Протокол для стратегии агитации
protocol AgitationStrategy {
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase
    var description: String { get }
}

/// Протокол для фабрики создания стратегий агитации
protocol AgitationStrategyFactory {
    func createStrategy(for mode: AgitationModeType) -> AgitationStrategy
}

/// Протокол для репозитория режимов агитации
protocol AgitationModeRepository {
    func getAllPresets() -> [AgitationMode]
    func getPreset(by name: String) -> AgitationMode?
    func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode
}

// MARK: - Core Types

/// Типы режимов агитации
enum AgitationModeType: String, CaseIterable, Codable {
    case orwo = "orwo"
    case xtol = "xtol"
    case rae = "rae"
    case fixer = "fixer"
    case continuous = "continuous"
    case still = "still"
    case custom = "custom"
}

/// Фаза агитации
struct AgitationPhase {
    let agitationType: PhaseAgitationType
    let description: String
    
    enum PhaseAgitationType: Equatable, Codable {
        case continuous
        case still
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case periodic(intervalSeconds: Int)
        case custom(description: String)
    }
}

/// Основная модель режима агитации
struct AgitationMode: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let type: AgitationModeType
    let isCustom: Bool
    private let strategy: AgitationStrategy
    
    init(name: String, type: AgitationModeType, isCustom: Bool, strategy: AgitationStrategy) {
        self.name = name
        self.type = type
        self.isCustom = isCustom
        self.strategy = strategy
    }
    
    static func == (lhs: AgitationMode, rhs: AgitationMode) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.type == rhs.type && lhs.isCustom == rhs.isCustom
    }
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return strategy.getAgitationForMinute(minute, totalMinutes: totalMinutes)
    }
    
    var description: String {
        return strategy.description
    }
}

// MARK: - Strategy Implementations

/// Стратегия для непрерывной агитации
struct ContinuousAgitationStrategy: AgitationStrategy {
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationPhase(
            agitationType: .continuous,
            description: String(localized: "agitation_continuous")
        )
    }
    
    var description: String {
        return String(localized: "agitation_continuous")
    }
}

/// Стратегия для неподвижного режима
struct StillAgitationStrategy: AgitationStrategy {
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationPhase(
            agitationType: .still,
            description: String(localized: "agitation_still")
        )
    }
    
    var description: String {
        return String(localized: "agitation_still")
    }
}

/// Стратегия для циклической агитации
struct CycleAgitationStrategy: AgitationStrategy {
    let agitationSeconds: Int
    let restSeconds: Int
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationPhase(
            agitationType: .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds),
            description: String(format: String(localized: "agitation_cycle_format"), "\(agitationSeconds)", "\(restSeconds)")
        )
    }
    
    var description: String {
        return String(format: String(localized: "agitation_cycle_format"), "\(agitationSeconds)", "\(restSeconds)")
    }
}

/// Стратегия для сложной агитации с фазами
struct ComplexAgitationStrategy: AgitationStrategy {
    let phases: [AgitationPhase]
    let modeName: String
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        // Специальная логика для ORWO
        if modeName == String(localized: "agitation_orwo_name") {
            if minute == 1 || minute == totalMinutes {
                return AgitationPhase(
                    agitationType: .cycle(agitationSeconds: 45, restSeconds: 15),
                    description: String(format: String(localized: "agitation_cycle_format"), "45", "15")
                )
            } else {
                return AgitationPhase(
                    agitationType: .cycle(agitationSeconds: 15, restSeconds: 45),
                    description: String(format: String(localized: "agitation_cycle_format"), "15", "45")
                )
            }
        }
        
        // Для других режимов используем фазы
        return phases.first { phase in
            // Здесь нужно добавить логику определения диапазона минут
            // Пока возвращаем первую фазу
            return true
        } ?? phases.first ?? AgitationPhase(
            agitationType: .still,
            description: String(localized: "agitation_still")
        )
    }
    
    var description: String {
        switch modeName {
        case String(localized: "agitation_orwo_name"):
            return String(localized: "agitation_orwo_description")
        case String(localized: "agitation_rae_name"):
            return String(localized: "agitation_rae_description")
        case String(localized: "agitation_fixer_name"):
            return String(localized: "agitation_fixer_description")
        default:
            return " "
        }
    }
}

// MARK: - Factory Implementation

struct AgitationStrategyFactoryImpl: AgitationStrategyFactory {
    func createStrategy(for mode: AgitationModeType) -> AgitationStrategy {
        switch mode {
        case .continuous:
            return ContinuousAgitationStrategy()
        case .still:
            return StillAgitationStrategy()
        case .xtol:
            return CycleAgitationStrategy(agitationSeconds: 5, restSeconds: 25)
        case .orwo:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 45, restSeconds: 15), description: ""),
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 15, restSeconds: 45), description: "")
                ],
                modeName: String(localized: "agitation_orwo_name")
            )
        case .rae:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous, description: ""),
                    AgitationPhase(agitationType: .periodic(intervalSeconds: 10), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitation_rae_phase_2_rotations")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_per_minute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_7th_minute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_10th_minute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitation_rae_phase_1_rotation_every_5_minutes")), description: "")
                ],
                modeName: String(localized: "agitation_rae_name")
            )
        case .fixer:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous, description: ""),
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 0, restSeconds: 60), description: "")
                ],
                modeName: String(localized: "agitation_fixer_name")
            )
        case .custom:
            return CycleAgitationStrategy(agitationSeconds: 30, restSeconds: 30)
        }
    }
}

// MARK: - Repository Implementation

struct AgitationModeRepositoryImpl: AgitationModeRepository {
    private let factory: AgitationStrategyFactory
    
    init(factory: AgitationStrategyFactory = AgitationStrategyFactoryImpl()) {
        self.factory = factory
    }
    
    func getAllPresets() -> [AgitationMode] {
        return [
            AgitationMode(
                name: String(localized: "agitation_orwo_name"),
                type: .orwo,
                isCustom: false,
                strategy: factory.createStrategy(for: .orwo)
            ),
            AgitationMode(
                name: String(localized: "agitation_xtol_name"),
                type: .xtol,
                isCustom: false,
                strategy: factory.createStrategy(for: .xtol)
            ),
            AgitationMode(
                name: String(localized: "agitation_rae_name"),
                type: .rae,
                isCustom: false,
                strategy: factory.createStrategy(for: .rae)
            ),
            AgitationMode(
                name: String(localized: "agitation_fixer_name"),
                type: .fixer,
                isCustom: false,
                strategy: factory.createStrategy(for: .fixer)
            ),
            AgitationMode(
                name: String(localized: "agitation_continuous_name"),
                type: .continuous,
                isCustom: false,
                strategy: factory.createStrategy(for: .continuous)
            ),
            AgitationMode(
                name: String(localized: "agitation_still_name"),
                type: .still,
                isCustom: false,
                strategy: factory.createStrategy(for: .still)
            )
        ]
    }
    
    func getPreset(by name: String) -> AgitationMode? {
        return getAllPresets().first { $0.name == name }
    }
    
    func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        let strategy = CycleAgitationStrategy(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
        return AgitationMode(
            name: String(format: String(localized: "agitation_custom_format"), "\(agitationSeconds)", "\(restSeconds)"),
            type: .custom,
            isCustom: true,
            strategy: strategy
        )
    }
}

// MARK: - Service Layer

/// Сервис для работы с режимами агитации
class AgitationModeService {
    private let repository: AgitationModeRepository
    
    init(repository: AgitationModeRepository = AgitationModeRepositoryImpl()) {
        self.repository = repository
    }
    
    var presets: [AgitationMode] {
        return repository.getAllPresets()
    }
    
    func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        return repository.createCustomMode(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
    }
    
    func getPreset(by name: String) -> AgitationMode? {
        return repository.getPreset(by: name)
    }
}

// MARK: - Legacy Support

// Для обратной совместимости
extension AgitationMode {
    static let presets: [AgitationMode] = AgitationModeService().presets
    
    static func createCustomMode(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        return AgitationModeService().createCustomMode(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
    }
    
    func getAgitationForMinute(_ minute: Int) -> AgitationPhase? {
        return getAgitationForMinute(minute, totalMinutes: Int.max)
    }
    
    func getAgitationForMinuteWithTotal(_ minute: Int, totalMinutes: Int) -> AgitationPhase? {
        return getAgitationForMinute(minute, totalMinutes: totalMinutes)
    }
}
