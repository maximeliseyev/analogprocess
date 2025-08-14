import Foundation
import SwiftUI
import Combine

class StagingViewModel: ObservableObject {
    @Published var allStages: [StagingStage] = StagingStage.defaultStages
    @Published var selectedStages: [StagingStage] = []
    @Published var selectedStage: StagingStage?
    @Published var isEditing = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Здесь можно добавить привязки для обновления данных
    }
    
    func addStage(_ stage: StagingStage) {
        var newStage = stage
        newStage.id = UUID()
        selectedStages.append(newStage)
    }
    
    func duplicateStage(_ stage: StagingStage) {
        var duplicatedStage = stage
        duplicatedStage.id = UUID()
        selectedStages.append(duplicatedStage)
    }
    
    func removeStage(at index: Int) {
        guard index >= 0 && index < selectedStages.count else { return }
        selectedStages.remove(at: index)
    }
    
    func getAvailableStages() -> [StagingStage] {
        // Возвращаем все стадии - они больше не исчезают из списка
        return allStages
    }
    
    func updateStageDuration(_ stage: StagingStage, duration: TimeInterval) {
        if let index = selectedStages.firstIndex(where: { $0.id == stage.id }) {
            selectedStages[index].duration = duration
        }
    }
    
    func updateStageTemperature(_ stage: StagingStage, temperature: Double) {
        if let index = selectedStages.firstIndex(where: { $0.id == stage.id }) {
            selectedStages[index].temperature = temperature
        }
    }
    
    func selectStage(_ stage: StagingStage) {
        selectedStage = stage
    }
    
    func getTotalDuration() -> TimeInterval {
        return selectedStages.reduce(0) { $0 + $1.duration }
    }
    
    func getEnabledStages() -> [StagingStage] {
        return selectedStages.filter { $0.isEnabled }
    }
} 