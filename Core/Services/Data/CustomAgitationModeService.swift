import Foundation
import SwiftData

/// Сервис для работы с пользовательскими режимами агитации
@MainActor
class CustomAgitationModeService: ObservableObject {
    private let modelContext: ModelContext
    
    @Published var savedModes: [SwiftDataCustomAgitationMode] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSavedModes()
    }
    
    // MARK: - Public Methods
    
    /// Загрузка всех сохраненных режимов
    func loadSavedModes() {
        isLoading = true
        error = nil
        
        do {
            let descriptor = FetchDescriptor<SwiftDataCustomAgitationMode>(
                sortBy: [SortDescriptor(\SwiftDataCustomAgitationMode.updatedAt, order: .reverse)]
            )
            
            savedModes = try modelContext.fetch(descriptor)
        } catch {
            self.error = error
            savedModes = []
            print("Error loading saved modes: \\(error)")
        }
        
        isLoading = false
    }
    
    /// Сохранение нового режима
    func saveMode(_ config: CustomAgitationConfig) throws -> SwiftDataCustomAgitationMode {
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
        
        loadSavedModes() // Перезагружаем список
        return newMode
    }
    
    /// Обновление существующего режима
    func updateMode(_ mode: SwiftDataCustomAgitationMode, with config: CustomAgitationConfig) throws {
        mode.update(from: config)
        try modelContext.save()
        loadSavedModes() // Перезагружаем список
    }
    
    /// Удаление режима
    func deleteMode(_ mode: SwiftDataCustomAgitationMode) throws {
        modelContext.delete(mode)
        try modelContext.save()
        loadSavedModes() // Перезагружаем список
    }
    
    /// Получение режима по ID
    func getMode(by id: String) -> SwiftDataCustomAgitationMode? {
        return savedModes.first { $0.id == id }
    }
    
    /// Поиск режимов по имени
    func searchModes(by name: String) -> [SwiftDataCustomAgitationMode] {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return savedModes
        }
        
        return savedModes.filter { mode in
            mode.name.localizedCaseInsensitiveContains(name)
        }
    }
    
    /// Проверка уникальности имени режима
    func isNameUnique(_ name: String, excluding excludeId: String? = nil) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !savedModes.contains { mode in
            if let excludeId = excludeId, mode.id == excludeId {
                return false // Исключаем режим, который редактируем
            }
            return mode.name.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }
    }
    
    /// Создание дубликата режима с новым именем
    func duplicateMode(_ originalMode: SwiftDataCustomAgitationMode, newName: String) throws -> SwiftDataCustomAgitationMode {
        let config = CustomAgitationConfig(
            name: newName,
            firstMinute: AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: originalMode.firstMinuteAgitationType) ?? .continuous,
                agitationSeconds: originalMode.firstMinuteAgitationSeconds,
                restSeconds: originalMode.firstMinuteRestSeconds,
                customDescription: originalMode.firstMinuteCustomDescription
            ),
            intermediate: AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: originalMode.intermediateAgitationType) ?? .cycle,
                agitationSeconds: originalMode.intermediateAgitationSeconds,
                restSeconds: originalMode.intermediateRestSeconds,
                customDescription: originalMode.intermediateCustomDescription
            ),
            hasLastMinuteCustom: originalMode.hasLastMinuteCustom,
            lastMinute: originalMode.hasLastMinuteCustom ? AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: originalMode.lastMinuteAgitationType ?? "still") ?? .still,
                agitationSeconds: originalMode.lastMinuteAgitationSeconds,
                restSeconds: originalMode.lastMinuteRestSeconds,
                customDescription: originalMode.lastMinuteCustomDescription
            ) : nil
        )
        
        return try saveMode(config)
    }
    
    /// Экспорт конфигурации режима в JSON
    func exportModeConfiguration(_ mode: SwiftDataCustomAgitationMode) throws -> Data {
        let exportData = CustomAgitationExportData(
            name: mode.name,
            version: "1.0",
            exportedAt: Date(),
            firstMinute: PhaseExportData(
                type: mode.firstMinuteAgitationType,
                agitationSeconds: mode.firstMinuteAgitationSeconds,
                restSeconds: mode.firstMinuteRestSeconds,
                customDescription: mode.firstMinuteCustomDescription
            ),
            intermediate: PhaseExportData(
                type: mode.intermediateAgitationType,
                agitationSeconds: mode.intermediateAgitationSeconds,
                restSeconds: mode.intermediateRestSeconds,
                customDescription: mode.intermediateCustomDescription
            ),
            hasLastMinuteCustom: mode.hasLastMinuteCustom,
            lastMinute: mode.hasLastMinuteCustom ? PhaseExportData(
                type: mode.lastMinuteAgitationType ?? "still",
                agitationSeconds: mode.lastMinuteAgitationSeconds,
                restSeconds: mode.lastMinuteRestSeconds,
                customDescription: mode.lastMinuteCustomDescription
            ) : nil
        )
        
        return try JSONEncoder().encode(exportData)
    }
    
    /// Импорт конфигурации режима из JSON
    func importModeConfiguration(from data: Data) throws -> SwiftDataCustomAgitationMode {
        let importData = try JSONDecoder().decode(CustomAgitationExportData.self, from: data)
        
        var config = CustomAgitationConfig(
            name: importData.name,
            firstMinute: AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: importData.firstMinute.type) ?? .continuous,
                agitationSeconds: importData.firstMinute.agitationSeconds,
                restSeconds: importData.firstMinute.restSeconds,
                customDescription: importData.firstMinute.customDescription
            ),
            intermediate: AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: importData.intermediate.type) ?? .cycle,
                agitationSeconds: importData.intermediate.agitationSeconds,
                restSeconds: importData.intermediate.restSeconds,
                customDescription: importData.intermediate.customDescription
            ),
            hasLastMinuteCustom: importData.hasLastMinuteCustom,
            lastMinute: importData.lastMinute != nil ? AgitationPhaseConfig(
                type: AgitationPhaseConfig.PhaseType(rawValue: importData.lastMinute!.type) ?? .still,
                agitationSeconds: importData.lastMinute!.agitationSeconds,
                restSeconds: importData.lastMinute!.restSeconds,
                customDescription: importData.lastMinute!.customDescription
            ) : nil
        )
        
        // Проверка на уникальность имени, если нет - добавляем суффикс
        var finalName = config.name
        var counter = 1
        while !isNameUnique(finalName) {
            finalName = "\\(config.name) (\\(counter))"
            counter += 1
        }
        config.name = finalName
        
        return try saveMode(config)
    }
}

// MARK: - Export/Import Data Structures

struct CustomAgitationExportData: Codable {
    let name: String
    let version: String
    let exportedAt: Date
    let firstMinute: PhaseExportData
    let intermediate: PhaseExportData
    let hasLastMinuteCustom: Bool
    let lastMinute: PhaseExportData?
}

struct PhaseExportData: Codable {
    let type: String
    let agitationSeconds: Int
    let restSeconds: Int
    let customDescription: String?
}
