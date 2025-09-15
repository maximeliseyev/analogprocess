import Foundation
import SwiftData

// MARK: - SwiftData Models for Custom Agitation

/// Модель для сохранения кастомного режима агитации в SwiftData
@Model
public final class SwiftDataCustomAgitationMode {
    @Attribute(.unique) public var id: String
    public var name: String
    public var createdAt: Date
    public var updatedAt: Date
    
    // Агитация для первой минуты
    public var firstMinuteAgitationType: String
    public var firstMinuteAgitationSeconds: Int
    public var firstMinuteRestSeconds: Int
    public var firstMinuteCustomDescription: String?
    
    // Агитация для промежуточных минут  
    public var intermediateAgitationType: String
    public var intermediateAgitationSeconds: Int
    public var intermediateRestSeconds: Int
    public var intermediateCustomDescription: String?
    
    // Агитация для последней минуты (опционально)
    public var hasLastMinuteCustom: Bool
    public var lastMinuteAgitationType: String?
    public var lastMinuteAgitationSeconds: Int
    public var lastMinuteRestSeconds: Int
    public var lastMinuteCustomDescription: String?
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        firstMinuteAgitationType: String,
        firstMinuteAgitationSeconds: Int = 0,
        firstMinuteRestSeconds: Int = 0,
        firstMinuteCustomDescription: String? = nil,
        intermediateAgitationType: String,
        intermediateAgitationSeconds: Int = 0,
        intermediateRestSeconds: Int = 0,
        intermediateCustomDescription: String? = nil,
        hasLastMinuteCustom: Bool = false,
        lastMinuteAgitationType: String? = nil,
        lastMinuteAgitationSeconds: Int = 0,
        lastMinuteRestSeconds: Int = 0,
        lastMinuteCustomDescription: String? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.firstMinuteAgitationType = firstMinuteAgitationType
        self.firstMinuteAgitationSeconds = firstMinuteAgitationSeconds
        self.firstMinuteRestSeconds = firstMinuteRestSeconds
        self.firstMinuteCustomDescription = firstMinuteCustomDescription
        self.intermediateAgitationType = intermediateAgitationType
        self.intermediateAgitationSeconds = intermediateAgitationSeconds
        self.intermediateRestSeconds = intermediateRestSeconds
        self.intermediateCustomDescription = intermediateCustomDescription
        self.hasLastMinuteCustom = hasLastMinuteCustom
        self.lastMinuteAgitationType = lastMinuteAgitationType
        self.lastMinuteAgitationSeconds = lastMinuteAgitationSeconds
        self.lastMinuteRestSeconds = lastMinuteRestSeconds
        self.lastMinuteCustomDescription = lastMinuteCustomDescription
    }
}

// MARK: - Conversion Extensions

extension SwiftDataCustomAgitationMode {
    /// Конвертирует SwiftData модель в AgitationMode
    func toAgitationMode() -> AgitationMode {
        let strategy = CustomUserDefinedAgitationStrategy(
            firstMinutePhase: createAgitationPhase(
                type: firstMinuteAgitationType,
                agitationSeconds: firstMinuteAgitationSeconds,
                restSeconds: firstMinuteRestSeconds,
                customDescription: firstMinuteCustomDescription
            ),
            intermediatePhase: createAgitationPhase(
                type: intermediateAgitationType,
                agitationSeconds: intermediateAgitationSeconds,
                restSeconds: intermediateRestSeconds,
                customDescription: intermediateCustomDescription
            ),
            lastMinutePhase: hasLastMinuteCustom ? createAgitationPhase(
                type: lastMinuteAgitationType ?? "still",
                agitationSeconds: lastMinuteAgitationSeconds,
                restSeconds: lastMinuteRestSeconds,
                customDescription: lastMinuteCustomDescription
            ) : nil
        )
        
        return AgitationMode(
            name: name,
            type: .custom,
            isCustom: true,
            strategy: strategy
        )
    }
    
    /// Создает AgitationPhase из параметров
    private func createAgitationPhase(
        type: String,
        agitationSeconds: Int,
        restSeconds: Int,
        customDescription: String?
    ) -> AgitationPhase {
        let agitationType: AgitationPhase.PhaseAgitationType
        
        switch type {
        case "continuous":
            agitationType = .continuous
        case "still":
            agitationType = .still
        case "cycle":
            agitationType = .cycle(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
        case "periodic":
            agitationType = .periodic(intervalSeconds: agitationSeconds)
        case "custom":
            agitationType = .custom(description: customDescription ?? "")
        default:
            agitationType = .still
        }
        
        return AgitationPhase(agitationType: agitationType)
    }
    
    /// Обновляет данные модели
    func update(from config: CustomAgitationConfig) {
        self.name = config.name
        self.updatedAt = Date()
        
        // First minute
        self.firstMinuteAgitationType = config.firstMinute.type.rawValue
        self.firstMinuteAgitationSeconds = config.firstMinute.agitationSeconds
        self.firstMinuteRestSeconds = config.firstMinute.restSeconds
        self.firstMinuteCustomDescription = config.firstMinute.customDescription
        
        // Intermediate minutes
        self.intermediateAgitationType = config.intermediate.type.rawValue
        self.intermediateAgitationSeconds = config.intermediate.agitationSeconds
        self.intermediateRestSeconds = config.intermediate.restSeconds
        self.intermediateCustomDescription = config.intermediate.customDescription
        
        // Last minute
        self.hasLastMinuteCustom = config.hasLastMinuteCustom
        if let lastMinute = config.lastMinute {
            self.lastMinuteAgitationType = lastMinute.type.rawValue
            self.lastMinuteAgitationSeconds = lastMinute.agitationSeconds
            self.lastMinuteRestSeconds = lastMinute.restSeconds
            self.lastMinuteCustomDescription = lastMinute.customDescription
        }
    }
}

// MARK: - Configuration Models

/// Конфигурация одной фазы агитации
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

/// Полная конфигурация кастомного режима агитации
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
}

// MARK: - Custom Strategy

/// Стратегия агитации для пользовательских режимов
public struct CustomUserDefinedAgitationStrategy: AgitationStrategy {
    let firstMinutePhase: AgitationPhase
    let intermediatePhase: AgitationPhase
    let lastMinutePhase: AgitationPhase?
    
    init(
        firstMinutePhase: AgitationPhase,
        intermediatePhase: AgitationPhase,
        lastMinutePhase: AgitationPhase? = nil
    ) {
        self.firstMinutePhase = firstMinutePhase
        self.intermediatePhase = intermediatePhase
        self.lastMinutePhase = lastMinutePhase
    }
    
    func getAgitationForMinute(_ minute: Int, totalMinutes: Int) -> AgitationPhase {
        if minute == 1 {
            return firstMinutePhase
        } else if minute == totalMinutes && lastMinutePhase != nil {
            return lastMinutePhase!
        } else {
            return intermediatePhase
        }
    }
    
    public var description: String {
        var components: [String] = []
        
        components.append("1-я мин: \(firstMinutePhase.description)")
        components.append("Остальные: \(intermediatePhase.description)")
        
        if let lastMinute = lastMinutePhase {
            components.append("Последняя: \(lastMinute.description)")
        }
        
        return components.joined(separator: " | ")
    }
}
