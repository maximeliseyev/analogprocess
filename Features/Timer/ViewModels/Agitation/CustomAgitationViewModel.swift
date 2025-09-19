import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class CustomAgitationViewModel {
    // MARK: - Published Properties

    /// Текущая конфигурация режима агитации
    var config = CustomAgitationConfig()

    /// Состояние сохранения
    var isSaving = false
    var saveError: Error?
    var showSaveError = false

    /// Состояние загрузки
    var isLoading = false
    var savedModes: [AgitationMode] = []

    /// UI состояние
    var showValidationErrors = false
    var isEditingMode = false
    var editingModeId: String?

    // MARK: - Dependencies

    private let customService: CustomAgitationModeService

    // MARK: - Init

    init(modelContext: ModelContext?) {
        if let modelContext = modelContext {
            self.customService = CustomAgitationModeService(modelContext: modelContext)
            loadSavedModes()
        } else {
            // Временная инициализация без service - будет переинициализирован в onAppear
            self.customService = CustomAgitationModeService(modelContext: nil)
        }
    }

    // MARK: - Public Methods

    /// Валидация текущей конфигурации
    func validateConfiguration() -> [String] {
        var errors: [String] = []

        // Проверка имени
        if config.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(String(localized: "customAgitationErrorEmptyName"))
        }

        // Проверка первой минуты
        if let error = validatePhase(config.firstMinute, phaseName: String(localized: "customAgitationFirstMinute")) {
            errors.append(error)
        }

        // Проверка промежуточных минут
        if let error = validatePhase(config.intermediate, phaseName: String(localized: "customAgitationIntermediate")) {
            errors.append(error)
        }

        // Проверка последней минуты (если включена)
        if config.hasLastMinuteCustom {
            if let lastMinute = config.lastMinute {
                if let error = validatePhase(lastMinute, phaseName: String(localized: "customAgitationLastMinute")) {
                    errors.append(error)
                }
            } else {
                errors.append(String(localized: "customAgitationErrorNoLastMinuteConfig"))
            }
        }

        return errors
    }

    /// Сохранение режима агитации
    func saveMode() async {
        let errors = validateConfiguration()
        if !errors.isEmpty {
            showValidationErrors = true
            return
        }

        isSaving = true
        saveError = nil

        do {
            if isEditingMode, let oldName = editingModeId {
                // Обновление существующего режима
                let enhancedConfig = config.toEnhanced()
                _ = try customService.updateCustomMode(oldName: oldName, config: enhancedConfig)
            } else {
                // Создание нового режима
                let enhancedConfig = config.toEnhanced()
                _ = try customService.saveCustomMode(config: enhancedConfig)
            }

            loadSavedModes() // Перезагрузка списка
            resetConfiguration() // Сброс формы
        } catch {
            saveError = error
            showSaveError = true
        }

        isSaving = false
    }

    /// Загрузка режима для редактирования (заглушка - требует реализации конвертации)
    func loadModeForEditing(_ mode: AgitationMode) {
        guard mode.isCustom else { return }
        isEditingMode = true
        editingModeId = mode.name

        // TODO: Реализовать обратную конвертацию из AgitationMode в CustomAgitationConfig
        // Пока что просто загружаем имя
        config.name = mode.name

        // Устанавливаем значения по умолчанию
        config.firstMinute = AgitationPhaseConfig(type: .continuous)
        config.intermediate = AgitationPhaseConfig(type: .cycle, agitationSeconds: 30, restSeconds: 30)
        config.hasLastMinuteCustom = false
        config.lastMinute = nil
    }

    /// Удаление режима
    func deleteMode(_ mode: AgitationMode) {
        guard mode.isCustom else { return }

        do {
            try customService.deleteCustomMode(named: mode.name)
            loadSavedModes()
        } catch {
            saveError = error
            showSaveError = true
        }
    }

    /// Сброс конфигурации
    func resetConfiguration() {
        config = CustomAgitationConfig()
        isEditingMode = false
        editingModeId = nil
        showValidationErrors = false
    }

    /// Переключение использования кастомной последней минуты
    func toggleLastMinuteCustom() {
        config.hasLastMinuteCustom.toggle()
        if config.hasLastMinuteCustom && config.lastMinute == nil {
            config.lastMinute = AgitationPhaseConfig(type: .still)
        } else if !config.hasLastMinuteCustom {
            config.lastMinute = nil
        }
    }

    // MARK: - Private Methods

    /// Валидация отдельной фазы
    private func validatePhase(_ phase: AgitationPhaseConfig, phaseName: String) -> String? {
        if phase.type.requiresCustomDescription {
            if phase.customDescription?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                return String(format: String(localized: "customAgitationErrorEmptyCustomDescription"), phaseName)
            }
        }

        if phase.type.requiresTiming {
            if phase.type == .cycle {
                if phase.agitationSeconds <= 0 && phase.restSeconds <= 0 {
                    return String(format: String(localized: "customAgitationErrorInvalidTiming"), phaseName)
                }
            } else if phase.type == .periodic {
                if phase.agitationSeconds <= 0 {
                    return String(format: String(localized: "customAgitationErrorInvalidInterval"), phaseName)
                }
            }
        }

        return nil
    }

    /// Загрузка сохраненных режимов
    private func loadSavedModes() {
        isLoading = true
        savedModes = customService.getCustomModes()
        isLoading = false
    }
}

// MARK: - Convenience Extensions

extension CustomAgitationViewModel {
    /// Проверка на валидность конфигурации
    var isConfigurationValid: Bool {
        return validateConfiguration().isEmpty
    }

    /// Получение режима агитации из текущей конфигурации
    func getAgitationMode() -> AgitationMode? {
        guard isConfigurationValid else { return nil }

        do {
            let enhancedConfig = config.toEnhanced()
            return try customService.saveCustomMode(config: enhancedConfig)
        } catch {
            return nil
        }
    }
}