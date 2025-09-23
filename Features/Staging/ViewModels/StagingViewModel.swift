import Foundation
import SwiftUI
import Combine


class StagingViewModel: ObservableObject {
    @Published var allStages: [StagingStage] = StagingStage.defaultStages
    @Published var selectedStages: [StagingStage] = []
    @Published var selectedStage: StagingStage?
    @Published var isEditing = false
    
    let availablePresets: [ProcessPreset]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.availablePresets = PresetService.getAvailablePresets()
        loadSelectedStages()
        setupBindings()
    }
    
    private func setupBindings() {
        // Автоматически сохраняем состояние при изменении selectedStages
        $selectedStages
            .sink { [weak self] stages in
                self?.saveSelectedStages()
            }
            .store(in: &cancellables)
    }
    
    func loadPreset(preset: ProcessPreset) {
        // Replace current stages with preset stages
        selectedStages = preset.stages
    }
    
    private func loadSelectedStages() {
        guard let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.selectedStages),
              let stages = try? JSONDecoder().decode([StagingStage].self, from: data) else {
            return
        }
        selectedStages = stages
    }
    
    private func saveSelectedStages() {
        guard let data = try? JSONEncoder().encode(selectedStages) else { return }
        UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.selectedStages)
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
    
    func updateStage(_ stage: StagingStage) {
        if let index = selectedStages.firstIndex(where: { $0.id == stage.id }) {
            selectedStages[index] = stage
        }
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
    
    func updateStageTemperature(_ stage: StagingStage, temperature: Int) {
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
    
    func startStagingTimer() {
        // Этот метод будет вызываться из StagingView
        // Логика показа TimerView в staging режиме находится в StagingView
    }
    
    func resetStages() {
        selectedStages = []
    }
} 
