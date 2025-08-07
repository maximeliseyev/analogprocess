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
            description: String(localized: "agitationContinuous")
        )
    }
    
    var description: String {
        return String(localized: "agitationContinuous")
    }
}

/// Стратегия для неподвижного режима
struct StillAgitationStrategy: AgitationStrategy {
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationPhase(
            agitationType: .still,
            description: String(localized: "agitationStill")
        )
    }
    
    var description: String {
        return String(localized: "agitationStill")
    }
}

/// Стратегия для циклической агитации
struct CycleAgitationStrategy: AgitationStrategy {
    let agitationSeconds: Int
    let restSeconds: Int
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationPhase(
            agitationType: .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds),
            description: String(format: String(localized: "agitationCycleFormat"), "\(agitationSeconds)", "\(restSeconds)")
        )
    }
    
    var description: String {
        return String(format: String(localized: "agitationCycleFormat"), "\(agitationSeconds)", "\(restSeconds)")
    }
}

/// Стратегия для сложной агитации с фазами
struct ComplexAgitationStrategy: AgitationStrategy {
    let phases: [AgitationPhase]
    let modeName: String
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        // Специальная логика для ORWO
        if modeName == String(localized: "agitationOrwoName") {
            if minute == 1 || minute == totalMinutes {
                return AgitationPhase(
                    agitationType: .cycle(agitationSeconds: 45, restSeconds: 15),
                    description: String(format: String(localized: "agitationCycleFormat"), "45", "15")
                )
            } else {
                return AgitationPhase(
                    agitationType: .cycle(agitationSeconds: 15, restSeconds: 45),
                    description: String(format: String(localized: "agitationCycleFormat"), "15", "45")
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
            description: String(localized: "agitationStill")
        )
    }
    
    var description: String {
        switch modeName {
        case String(localized: "agitationOrwoName"):
            return String(localized: "agitationOrwoDescription")
        case String(localized: "agitationRaeName"):
            return String(localized: "agitationRaeDescription")
        case String(localized: "agitationFixerName"):
            return String(localized: "agitationFixerDescription")
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
                modeName: String(localized: "agitationOrwoName")
            )
        case .rae:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous, description: ""),
                    AgitationPhase(agitationType: .periodic(intervalSeconds: 10), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase2Rotations")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1RotationPerMinute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1Rotation7thMinute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1Rotation10thMinute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1RotationEvery5Minutes")), description: "")
                ],
                modeName: String(localized: "agitationRaeName")
            )
        case .fixer:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous, description: ""),
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 0, restSeconds: 60), description: "")
                ],
                modeName: String(localized: "agitationFixerName")
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
                name: String(localized: "agitationOrwoName"),
                type: .orwo,
                isCustom: false,
                strategy: factory.createStrategy(for: .orwo)
            ),
            AgitationMode(
                name: String(localized: "agitationXtolName"),
                type: .xtol,
                isCustom: false,
                strategy: factory.createStrategy(for: .xtol)
            ),
            AgitationMode(
                name: String(localized: "agitationRaeName"),
                type: .rae,
                isCustom: false,
                strategy: factory.createStrategy(for: .rae)
            ),
            AgitationMode(
                name: String(localized: "agitationFixerName"),
                type: .fixer,
                isCustom: false,
                strategy: factory.createStrategy(for: .fixer)
            ),
            AgitationMode(
                name: String(localized: "agitationContinuousName"),
                type: .continuous,
                isCustom: false,
                strategy: factory.createStrategy(for: .continuous)
            ),
            AgitationMode(
                name: String(localized: "agitationStillName"),
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
            name: String(format: String(localized: "agitationCustomFormat"), "\(agitationSeconds)", "\(restSeconds)"),
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
