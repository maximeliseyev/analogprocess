import Foundation

/// UI-модель для конфигурации фазы агитации в редакторе кастомных режимов
struct AgitationPhaseConfig {
    var type: PhaseType
    var agitationSeconds: Int
    var restSeconds: Int
    var customDescription: String?

    init(type: PhaseType, agitationSeconds: Int = 0, restSeconds: Int = 0, customDescription: String? = nil) {
        self.type = type
        self.agitationSeconds = agitationSeconds
        self.restSeconds = restSeconds
        self.customDescription = customDescription
    }
}

// MARK: - PhaseType

extension AgitationPhaseConfig {
    enum PhaseType: String, CaseIterable, Identifiable {
        case continuous
        case still
        case cycle
        case periodic
        case custom

        var id: String { rawValue }

        var localizedName: String {
            switch self {
            case .continuous:
                return String(localized: "continuous")
            case .still:
                return String(localized: "still")
            case .cycle:
                return String(localized: "cycle")
            case .periodic:
                return String(localized: "periodic")
            case .custom:
                return String(localized: "custom")
            }
        }

        var requiresTiming: Bool {
            switch self {
            case .cycle, .periodic:
                return true
            case .continuous, .still, .custom:
                return false
            }
        }

        var requiresCustomDescription: Bool {
            return self == .custom
        }
    }
}