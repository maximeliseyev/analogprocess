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
        selectedStages.append(stage)
    }
    
    func removeStage(at index: Int) {
        guard index >= 0 && index < selectedStages.count else { return }
        selectedStages.remove(at: index)
    }
    
    func moveStage(from fromIndex: Int, to toIndex: Int) {
        guard fromIndex >= 0 && fromIndex < selectedStages.count,
              toIndex >= 0 && toIndex < selectedStages.count else { return }
        
        let stage = selectedStages.remove(at: fromIndex)
        selectedStages.insert(stage, at: toIndex)
    }
    
    func getAvailableStages() -> [StagingStage] {
        // Возвращаем все стадии, которые еще не выбраны
        return allStages.filter { stage in
            !selectedStages.contains { $0.id == stage.id }
        }
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