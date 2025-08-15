//
//  StagingTimerViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import Combine
import Foundation

@MainActor
class StagingTimerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStageIndex = 0
    @Published var isRunning = false
    @Published var isTimerFinished = false
    @Published var progress: Double = 0.0
    @Published var displayMinutes = 0
    @Published var displaySeconds = 0
    @Published var selectedAgitationMode: AgitationMode?
    @Published var showAgitationSelection = false
    
    // MARK: - Agitation Properties
    @Published var shouldAgitate = false
    @Published var isInAgitationPhase = false
    @Published var agitationTimeRemaining = 0
    @Published var currentMinute = 0
    @Published var currentAgitationPhase: AgitationPhase.PhaseAgitationType?
    
    // MARK: - Private Properties
    private let stages: [StagingStage]
    private var timer: Timer?
    private var totalSeconds = 0
    private var remainingSeconds = 0
    
    // MARK: - Computed Properties
    
    var currentStage: StagingStage? {
        guard currentStageIndex < stages.count else { return nil }
        return stages[currentStageIndex]
    }
    
    var hasNextStage: Bool {
        return currentStageIndex < stages.count - 1
    }
    
    // MARK: - Initialization
    
    init(stages: [StagingStage]) {
        self.stages = stages
        setupCurrentStage()
    }
    
    // MARK: - Public Methods
    
    func startPauseTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func resetTimer() {
        pauseTimer()
        setupCurrentStage()
    }
    
    func startNextStage() {
        guard hasNextStage else { return }
        
        currentStageIndex += 1
        isTimerFinished = false
        setupCurrentStage()
        startTimer()
    }
    
    func selectAgitationMode(_ mode: AgitationMode) {
        selectedAgitationMode = mode
        showAgitationSelection = false
    }
    
    // MARK: - Private Methods
    
    private func setupCurrentStage() {
        guard let stage = currentStage else { return }
        
        // Устанавливаем время стадии
        totalSeconds = Int(stage.duration)
        remainingSeconds = totalSeconds
        
        // Устанавливаем режим ажитации
        if let agitationPresetKey = stage.agitationPresetKey {
            // Ищем режим по локализованному названию
            selectedAgitationMode = AgitationMode.presets.first { $0.name == String(localized: String.LocalizationValue(agitationPresetKey)) }
            
            if selectedAgitationMode == nil {
                // Если не нашли по локализованному названию, попробуем найти по ключу
                selectedAgitationMode = AgitationMode.presets.first { $0.name == agitationPresetKey }
            }
        } else {
            // Если нет настроек ажитации, используем режим Still
            selectedAgitationMode = AgitationMode.presets.first { $0.type == .still }
        }
        
        updateDisplay()
        updateProgress()
        
        // Устанавливаем ажитацию после настройки режима
        setupAgitation()
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimer()
            }
        }
        
        // Запускаем ажитацию если есть
        setupAgitation()
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Останавливаем ажитацию
        stopAgitation()
    }
    
    private func updateTimer() {
        guard remainingSeconds > 0 else {
            finishTimer()
            return
        }
        
        remainingSeconds -= 1
        updateDisplay()
        updateProgress()
        updateCurrentMinute()
        updateAgitation()
    }
    
    private func updateCurrentMinute() {
        let elapsedMinutes = (totalSeconds - remainingSeconds) / 60
        currentMinute = elapsedMinutes + 1
    }
    
    private func updateDisplay() {
        displayMinutes = remainingSeconds / 60
        displaySeconds = remainingSeconds % 60
    }
    
    private func updateProgress() {
        progress = totalSeconds > 0 ? Double(totalSeconds - remainingSeconds) / Double(totalSeconds) : 0.0
    }
    
    private func finishTimer() {
        isRunning = false
        isTimerFinished = true
        timer?.invalidate()
        timer = nil
        stopAgitation()
    }
    
    // MARK: - Agitation Methods
    
    private func setupAgitation() {
        guard let mode = selectedAgitationMode else {
            shouldAgitate = false
            return
        }
        
        shouldAgitate = true
        currentAgitationPhase = mode.getAgitationForMinuteWithTotal(currentMinute, totalMinutes: totalSeconds / 60)?.agitationType
        
        if let phase = currentAgitationPhase {
            switch phase {
            case .continuous:
                isInAgitationPhase = true
                agitationTimeRemaining = 0
            case .still:
                isInAgitationPhase = false
                agitationTimeRemaining = 0
            case .cycle(let agitation, _):
                isInAgitationPhase = true
                agitationTimeRemaining = agitation
            case .periodic(let interval):
                isInAgitationPhase = true
                agitationTimeRemaining = interval
            case .custom:
                isInAgitationPhase = false
                agitationTimeRemaining = 0
            }
        }
    }

    private func updateAgitation() {
        guard shouldAgitate, let mode = selectedAgitationMode else { return }
        
        let newPhase = mode.getAgitationForMinuteWithTotal(currentMinute, totalMinutes: totalSeconds / 60)?.agitationType
        if newPhase != currentAgitationPhase {
            currentAgitationPhase = newPhase
            setupAgitation()
        }
        
        guard let phase = currentAgitationPhase else { return }
        
        switch phase {
        case .continuous:
            break
            
        case .still:
            break
            
        case .cycle(let agitation, let rest):
            // Проверяем, нужно ли переключиться в этой секунде
            if agitationTimeRemaining == 1 {
                // Переключаем режим
                let oldPhase = isInAgitationPhase ? "Agitation" : "Rest"
                if isInAgitationPhase {
                    isInAgitationPhase = false
                    agitationTimeRemaining = rest
                } else {
                    isInAgitationPhase = true
                    agitationTimeRemaining = agitation
                }
                let newPhase = isInAgitationPhase ? "Agitation" : "Rest"
                
                print("🔄 [\(Date())] Переключение режима: \(oldPhase) → \(newPhase) (время: \(agitationTimeRemaining)s)")
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            } else {
                // Просто уменьшаем счетчик
                agitationTimeRemaining -= 1
            }
            
        case .periodic(let interval):
            // Проверяем, нужно ли переключиться в этой секунде
            if agitationTimeRemaining == 1 {
                agitationTimeRemaining = interval
                
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            } else {
                agitationTimeRemaining -= 1
            }
            
        case .custom:
            break
        }
    }
    
    private func stopAgitation() {
        shouldAgitate = false
        isInAgitationPhase = false
    }
    
    deinit {
        timer?.invalidate()
    }
}
