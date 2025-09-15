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
    var savedModes: [SwiftDataCustomAgitationMode] = []
    
    /// UI состояние
    var showValidationErrors = false
    var isEditingMode = false
    var editingModeId: String?
    
    // MARK: - Dependencies
    
    private let modelContext: ModelContext
    
    // MARK: - Init
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSavedModes()
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
            if isEditingMode, let modeId = editingModeId {
                // Обновление существующего режима
                try await updateExistingMode(modeId: modeId)
            } else {
                // Создание нового режима
                try await createNewMode()
            }
            
            loadSavedModes() // Перезагрузка списка
            resetConfiguration() // Сброс формы
        } catch {
            saveError = error
            showSaveError = true
        }
        
        isSaving = false
    }
    
    /// Загрузка режима для редактирования
    func loadModeForEditing(_ mode: SwiftDataCustomAgitationMode) {
        isEditingMode = true
        editingModeId = mode.id
        
        config.name = mode.name
        
        // Загрузка первой минуты
        config.firstMinute = AgitationPhaseConfig(
            type: AgitationPhaseConfig.PhaseType(rawValue: mode.firstMinuteAgitationType) ?? .continuous,
            agitationSeconds: mode.firstMinuteAgitationSeconds,
            restSeconds: mode.firstMinuteRestSeconds,
            customDescription: mode.firstMinuteCustomDescription
        )
        
        // Загрузка промежуточных минут
        config.intermediate = AgitationPhaseConfig(
            type: AgitationPhaseConfig.PhaseType(rawValue: mode.intermediateAgitationType) ?? .cycle,
            agitationSeconds: mode.intermediateAgitationSeconds,
            restSeconds: mode.intermediateRestSeconds,
            customDescription: mode.intermediateCustomDescription
        )
        
        // Загрузка последней минуты
        config.hasLastMinuteCustom = mode.hasLastMinuteCustom
        if mode.hasLastMinuteCustom {
            config.lastMinute = AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: mode.lastMinuteAgitationType ?? "still") ?? .still,
                agitationSeconds: mode.lastMinuteAgitationSeconds,
                restSeconds: mode.lastMinuteRestSeconds,
                customDescription: mode.lastMinuteCustomDescription
            )
        }
    }
    
    /// Удаление режима
    func deleteMode(_ mode: SwiftDataCustomAgitationMode) {
        modelContext.delete(mode)
        try? modelContext.save()
        loadSavedModes()
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
    
    /// Создание нового режима
    private func createNewMode() async throws {
        let newMode = SwiftDataCustomAgitationMode(
            name: config.name,
            firstMinuteAgitationType: config.firstMinute.type.rawValue,
            firstMinuteAgitationSeconds: config.firstMinute.agitationSeconds,
            firstMinuteRestSeconds: config.firstMinute.restSeconds,
            firstMinuteCustomDescription: config.firstMinute.customDescription,
            intermediateAgitationType: config.intermediate.type.rawValue,
            intermediateAgitationSeconds: config.intermediate.agitationSeconds,
            intermediateRestSeconds: config.intermediate.restSeconds,
            intermediateCustomDescription: config.intermediate.customDescription,
            hasLastMinuteCustom: config.hasLastMinuteCustom,
            lastMinuteAgitationType: config.lastMinute?.type.rawValue,
            lastMinuteAgitationSeconds: config.lastMinute?.agitationSeconds ?? 0,
            lastMinuteRestSeconds: config.lastMinute?.restSeconds ?? 0,
            lastMinuteCustomDescription: config.lastMinute?.customDescription
        )
        
        modelContext.insert(newMode)
        try modelContext.save()
    }
    
    /// Обновление существующего режима
    private func updateExistingMode(modeId: String) async throws {
        let descriptor = FetchDescriptor<SwiftDataCustomAgitationMode>(
            predicate: #Predicate { mode in
                mode.id == modeId
            }
        )
        
        if let existingMode = try modelContext.fetch(descriptor).first {
            existingMode.update(from: config)
            try modelContext.save()
        }
    }
    
    /// Загрузка сохраненных режимов
    private func loadSavedModes() {
        isLoading = true
        
        let descriptor = FetchDescriptor<SwiftDataCustomAgitationMode>(
            sortBy: [SortDescriptor(\SwiftDataCustomAgitationMode.updatedAt, order: .reverse)]
        )
        
        do {
            savedModes = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading saved modes: \(error)")
            savedModes = []
        }
        
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
        
        let tempMode = SwiftDataCustomAgitationMode(
            name: config.name,
            firstMinuteAgitationType: config.firstMinute.type.rawValue,
            firstMinuteAgitationSeconds: config.firstMinute.agitationSeconds,
            firstMinuteRestSeconds: config.firstMinute.restSeconds,
            firstMinuteCustomDescription: config.firstMinute.customDescription,
            intermediateAgitationType: config.intermediate.type.rawValue,
            intermediateAgitationSeconds: config.intermediate.agitationSeconds,
            intermediateRestSeconds: config.intermediate.restSeconds,
            intermediateCustomDescription: config.intermediate.customDescription,
            hasLastMinuteCustom: config.hasLastMinuteCustom,
            lastMinuteAgitationType: config.lastMinute?.type.rawValue,
            lastMinuteAgitationSeconds: config.lastMinute?.agitationSeconds ?? 0,
            lastMinuteRestSeconds: config.lastMinute?.restSeconds ?? 0,
            lastMinuteCustomDescription: config.lastMinute?.customDescription
        )
        
        return tempMode.toAgitationMode()
    }
}
