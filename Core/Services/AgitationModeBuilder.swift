//
//  AgitationModeBuilder.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 23.07.2025.
//

import Foundation

// MARK: - Builder Pattern Implementation

/// Билдер для создания режимов агитации
class AgitationModeBuilder {
    private var name: String = ""
    private var type: AgitationModeType = .custom
    private var isCustom: Bool = false
    private var phases: [AgitationPhase] = []
    private var agitationSeconds: Int = 30
    private var restSeconds: Int = 30
    
    func setName(_ name: String) -> AgitationModeBuilder {
        self.name = name
        return self
    }
    
    func setType(_ type: AgitationModeType) -> AgitationModeBuilder {
        self.type = type
        return self
    }
    
    func setCustom(_ isCustom: Bool) -> AgitationModeBuilder {
        self.isCustom = isCustom
        return self
    }
    
    func setCycleParameters(agitationSeconds: Int, restSeconds: Int) -> AgitationModeBuilder {
        self.agitationSeconds = agitationSeconds
        self.restSeconds = restSeconds
        return self
    }
    
    func addPhase(_ phase: AgitationPhase) -> AgitationModeBuilder {
        self.phases.append(phase)
        return self
    }
    
    func build() -> AgitationMode {
        let strategy: AgitationStrategy
        
        switch type {
        case .continuous:
            strategy = ContinuousAgitationStrategy()
        case .still:
            strategy = StillAgitationStrategy()
        case .xtol:
            strategy = CycleAgitationStrategy(agitationSeconds: 5, restSeconds: 25)
        case .orwo:
            strategy = ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 45, restSeconds: 15), description: ""),
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 15, restSeconds: 45), description: "")
                ],
                modeName: name
            )
        case .rae:
            strategy = ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous, description: ""),
                    AgitationPhase(agitationType: .periodic(intervalSeconds: 10), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase2Rotations")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1RotationPerMinute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1Rotation7thMinute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1Rotation10thMinute")), description: ""),
                    AgitationPhase(agitationType: .custom(description: String(localized: "agitationRaePhase1RotationEvery5Minutes")), description: "")
                ],
                modeName: name
            )
        case .fixer:
            strategy = ComplexAgitationStrategy(
                phases: [
                    AgitationPhase(agitationType: .continuous, description: ""),
                    AgitationPhase(agitationType: .cycle(agitationSeconds: 0, restSeconds: 60), description: "")
                ],
                modeName: name
            )
        case .custom:
            strategy = CycleAgitationStrategy(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
        }
        
        return AgitationMode(name: name, type: type, isCustom: isCustom, strategy: strategy)
    }
}

// MARK: - Factory Methods

extension AgitationModeBuilder {
    /// Создает стандартный режим ORWO
    static func createORWO() -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(localized: "agitationOrwoName"))
            .setType(.orwo)
            .setCustom(false)
            .build()
    }
    
    /// Создает стандартный режим XTOL
    static func createXTOL() -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(localized: "agitationXtolName"))
            .setType(.xtol)
            .setCustom(false)
            .build()
    }
    
    /// Создает стандартный режим RAE
    static func createRAE() -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(localized: "agitationRaeName"))
            .setType(.rae)
            .setCustom(false)
            .build()
    }
    
    /// Создает стандартный режим Fixer
    static func createFixer() -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(localized: "agitationFixerName"))
            .setType(.fixer)
            .setCustom(false)
            .build()
    }
    
    /// Создает непрерывный режим
    static func createContinuous() -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(localized: "agitationContinuousName"))
            .setType(.continuous)
            .setCustom(false)
            .build()
    }
    
    /// Создает неподвижный режим
    static func createStill() -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(localized: "agitationStillName"))
            .setType(.still)
            .setCustom(false)
            .build()
    }
    
    /// Создает кастомный циклический режим
    static func createCustomCycle(agitationSeconds: Int, restSeconds: Int) -> AgitationMode {
        return AgitationModeBuilder()
            .setName(String(format: String(localized: "agitationCustomFormat"), "\(agitationSeconds)", "\(restSeconds)"))
            .setType(.custom)
            .setCustom(true)
            .setCycleParameters(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
            .build()
    }
} 