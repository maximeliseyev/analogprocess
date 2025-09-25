import Foundation

/// UI-модель для редактирования кастомных режимов агитации
struct UICustomAgitationConfig {
    var name: String
    var firstMinute: AgitationPhaseConfig
    var intermediate: AgitationPhaseConfig
    var lastMinute: AgitationPhaseConfig?
    var hasLastMinuteCustom: Bool

    init(name: String = "") {
        self.name = name
        self.firstMinute = AgitationPhaseConfig(type: .cycle, agitationSeconds: 10, restSeconds: 50)
        self.intermediate = AgitationPhaseConfig(type: .cycle, agitationSeconds: 10, restSeconds: 50)
        self.lastMinute = nil
        self.hasLastMinuteCustom = false
    }
}

// MARK: - Conversion to Service Model

extension UICustomAgitationConfig {
    /// Конвертирует UI-модель в модель для сохранения в сервисе
    func toEnhanced() -> CustomAgitationConfig {
        var rules: [CustomAgitationRule] = []

        // Первая минута
        rules.append(createRule(from: firstMinute, priority: 10, minuteCondition: 1))

        // Промежуточные минуты
        if hasLastMinuteCustom {
            // Если есть кастомная последняя минута, промежуточные - это 2...N-1
            rules.append(createRule(from: intermediate, priority: 20, minuteCondition: nil, excludeFirst: true, excludeLast: true))
        } else {
            // Если нет кастомной последней минуты, промежуточные - это 2...N
            rules.append(createRule(from: intermediate, priority: 20, minuteCondition: nil, excludeFirst: true))
        }

        // Последняя минута (если есть)
        if hasLastMinuteCustom, let lastMinute = lastMinute {
            rules.append(createRule(from: lastMinute, priority: 30, isLastMinute: true))
        }

        return CustomAgitationConfig(name: name, rules: rules)
    }

    private func createRule(
        from phaseConfig: AgitationPhaseConfig,
        priority: Int,
        minuteCondition: Int? = nil,
        excludeFirst: Bool = false,
        excludeLast: Bool = false,
        isLastMinute: Bool = false
    ) -> CustomAgitationRule {

        let action = convertPhaseTypeToAction(phaseConfig.type)
        let parameters = createParameters(from: phaseConfig)

        let conditionType: AgitationRuleConditionType
        var conditionValues: [Int] = []

        if let minute = minuteCondition {
            conditionType = .minute
            conditionValues = [minute]
        } else if isLastMinute {
            conditionType = .lastMinute
        } else if excludeFirst && excludeLast {
            conditionType = .minuteRange
            conditionValues = [2, -1] // 2 до предпоследней
        } else if excludeFirst {
            conditionType = .minuteRange
            conditionValues = [2, -1] // 2 до последней
        } else {
            conditionType = .always
        }

        return CustomAgitationRule(
            priority: priority,
            conditionType: conditionType,
            conditionValues: conditionValues,
            action: action,
            parameters: parameters
        )
    }

    private func convertPhaseTypeToAction(_ phaseType: AgitationPhaseConfig.PhaseType) -> AgitationAction {
        switch phaseType {
        case .continuous:
            return .continuous
        case .still:
            return .still
        case .cycle:
            return .cycle
        case .periodic:
            return .periodic
        case .custom:
            return .custom
        }
    }

    private func createParameters(from phaseConfig: AgitationPhaseConfig) -> [String: Int] {
        var parameters: [String: Int] = [:]

        switch phaseConfig.type {
        case .cycle:
            parameters["agitation_seconds"] = phaseConfig.agitationSeconds
            parameters["rest_seconds"] = phaseConfig.restSeconds
        case .periodic:
            parameters["interval_seconds"] = phaseConfig.agitationSeconds
        case .custom:
            // Для custom типа параметры не нужны, описание хранится отдельно
            break
        case .continuous, .still:
            // Для этих типов параметры не нужны
            break
        }

        return parameters
    }
}