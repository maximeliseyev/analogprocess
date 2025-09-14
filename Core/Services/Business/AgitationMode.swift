//
//  AgitationMode.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 23.07.2025.
//

import Foundation
2
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

// MARK: - Constants

/// Константы для настроек режимов агитации
enum AgitationConstants {
    enum XTOL {
        static let agitationSeconds = 5
        static let restSeconds = 25
    }
    
    enum ORWO {
        static let firstPhaseAgitation = 45
        static let firstPhaseRest = 15
        static let secondPhaseAgitation = 15
        static let secondPhaseRest = 45
    }
    
    enum RAE {
        static let periodicInterval = 10
    }
    
    enum Fixer {
        static let agitationSeconds = 0
        static let restSeconds = 60
    }
    
    enum Default {
        static let agitationSeconds = 30
        static let restSeconds = 30
    }
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
    
    init(agitationType: PhaseAgitationType, description: String = "") {
        self.agitationType = agitationType
        self.description = description.isEmpty ? agitationType.defaultDescription : description
    }
    
    enum PhaseAgitationType: Equatable, Codable {
        case continuous
        case still
        case cycle(agitationSeconds: Int, restSeconds: Int)
        case periodic(intervalSeconds: Int)
        case custom(description: String)
        
        var defaultDescription: String {
            switch self {
            case .continuous:
                return String(localized: "agitationContinuous")
            case .still:
                return String(localized: "agitationStill")
            case .cycle(let agitation, let rest):
                return String(format: String(localized: "agitationCycleFormat"), "\(agitation)", "\(rest)")
            case .periodic(let interval):
                return String(format: String(localized: "agitationPeriodicFormat"), "\(interval)")
            case .custom(let description):
                return description
            }
        }
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
        return AgitationPhase(agitationType: .continuous)
    }
    
    var description: String {
        return String(localized: "agitationContinuous")
    }
}

/// Стратегия для неподвижного режима
struct StillAgitationStrategy: AgitationStrategy {
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return AgitationPhase(agitationType: .still)
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
        return AgitationPhase(agitationType: .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds))
    }
    
    var description: String {
        return String(format: String(localized: "agitationCycleFormat"), "\(agitationSeconds)", "\(restSeconds)")
    }
}

/// Стратегия для ORWO агитации
struct ORWOAgitationStrategy: AgitationStrategy {
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        if minute == 1 || minute == totalMinutes {
            return AgitationPhase(agitationType: .cycle(agitationSeconds: AgitationConstants.ORWO.firstPhaseAgitation, restSeconds: AgitationConstants.ORWO.firstPhaseRest))
        } else {
            return AgitationPhase(agitationType: .cycle(agitationSeconds: AgitationConstants.ORWO.secondPhaseAgitation, restSeconds: AgitationConstants.ORWO.secondPhaseRest))
        }
    }
    
    var description: String {
        return String(localized: "agitationOrwoDescription")
    }
}

/// Стратегия для сложной агитации с фазами
struct ComplexAgitationStrategy: AgitationStrategy {
    let phases: [AgitationPhase]
    let strategyDescription: String
    private let phaseSelector: (Int, Int, [AgitationPhase]) -> AgitationPhase
    
    init(phases: [AgitationPhase], description: String, phaseSelector: @escaping (Int, Int, [AgitationPhase]) -> AgitationPhase = { _, _, phases in phases.first ?? AgitationPhase(agitationType: .still) }) {
        self.phases = phases
        self.strategyDescription = description
        self.phaseSelector = phaseSelector
    }
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        return phaseSelector(minute, totalMinutes, phases)
    }
    
    var description: String {
        return strategyDescription
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
            return CycleAgitationStrategy(agitationSeconds: AgitationConstants.XTOL.agitationSeconds, restSeconds: AgitationConstants.XTOL.restSeconds)
        case .orwo:
            return ORWOAgitationStrategy()
        case .rae:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous),
                    AgitationPhase(agitationType: .periodic(intervalSeconds: AgitationConstants.RAE.periodicInterval)),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase2Rotations"))),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1RotationPerMinute"))),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1Rotation7thMinute"))),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1Rotation10thMinute"))),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1RotationEvery5Minutes")))
                ],
                description: String(localized: "agitationRaeDescription")
            )
        case .fixer:
            return ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous),
                    AgitationPhase(agitationType: .cycle(agitationSeconds: AgitationConstants.Fixer.agitationSeconds, restSeconds: AgitationConstants.Fixer.restSeconds))
                ],
                description: String(localized: "agitationFixerDescription")
            )
        case .custom:
            return CycleAgitationStrategy(agitationSeconds: AgitationConstants.Default.agitationSeconds, restSeconds: AgitationConstants.Default.restSeconds)
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
