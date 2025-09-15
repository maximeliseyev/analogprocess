//
//  TimerViewModel.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import UIKit

@MainActor
class TimerViewModel: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var isRunning = false
    @Published var showingAlert = false
    @Published var showAgitationSelection = true
    @Published var selectedAgitationMode: AgitationMode?
    @Published var showManualTimeInput = false
    @Published var showFixingTimer = false
    @Published var isTimerFinished = false
    @Published var fixingMinutes: Int = 5
    @Published var fixingSeconds: Int = 0
    
    @Published var currentMinute: Int = 1
    @Published var shouldAgitate = false
    @Published var agitationTimeRemaining = 0
    @Published var isInAgitationPhase = false
    @Published var currentAgitationPhase: AgitationPhase.PhaseAgitationType?
    
    private var timer: Timer?
    private var totalMinutes: Int
    private var totalSeconds: Int
    
    var totalTime: Int {
        totalMinutes * 60 + totalSeconds
    }
    
    var currentTotalMinutes: Int {
        get { totalMinutes }
        set { totalMinutes = newValue }
    }
    
    var currentTotalSeconds: Int {
        get { totalSeconds }
        set { totalSeconds = newValue }
    }
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    var displayMinutes: Int {
        timeRemaining / 60
    }
    
    var displaySeconds: Int {
        timeRemaining % 60
    }
    
    init(totalMinutes: Int, totalSeconds: Int) {
        self.totalMinutes = totalMinutes
        self.totalSeconds = totalSeconds
        self.timeRemaining = totalTime
    }
    
    // MARK: - Public Methods
    
    func setupTimer(totalMinutes: Int, totalSeconds: Int) {
        // Этот метод может быть использован для обновления таймера, если нужно
        // В текущей реализации TimerViewModel уже инициализируется с правильными значениями
    }
    
    func startPauseTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = totalTime
        currentMinute = 1
        setupAgitation()
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func selectAgitationMode(_ mode: AgitationMode) {
        selectedAgitationMode = mode
        showAgitationSelection = false
        setupAgitation()
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        guard timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.timeRemaining -= 1
                if self.timeRemaining > 0 {
                    self.updateCurrentMinute()
                    self.updateAgitation()
                } else {
                    self.timerFinished()
                }
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func presentManualTimeInput() {
        showManualTimeInput = true
    }
    
    func updateTimerTime(minutes: Int, seconds: Int) {
        stopTimer()
        totalMinutes = minutes
        totalSeconds = minutes * 60 + seconds
        timeRemaining = totalTime
        currentMinute = 1
        setupAgitation()
        showManualTimeInput = false
    }
    
    func getPhaseDescription(_ phase: AgitationPhase.PhaseAgitationType) -> String {
        switch phase {
        case .continuous:
            return "Непрерывная ажитация"
        case .still:
            return "Без ажитации"
        case .cycle(let agitation, let rest):
            return "\(agitation)с ажитации / \(rest)с покоя"
        case .periodic(let interval):
            return "Каждые \(interval)с"
        case .custom(let description):
            return description
        }
    }
    
    // MARK: - Private Methods
    
    private func updateCurrentMinute() {
        let elapsedMinutes = (totalTime - timeRemaining) / 60
        currentMinute = elapsedMinutes + 1
    }
    
    private func setupAgitation() {
        guard let mode = selectedAgitationMode else {
            shouldAgitate = false
            return
        }
        
        shouldAgitate = true
        currentAgitationPhase = mode.getAgitationForMinuteWithTotal(currentMinute, totalMinutes: totalMinutes)?.agitationType
        
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
        
        let newPhase = mode.getAgitationForMinuteWithTotal(currentMinute, totalMinutes: totalMinutes)?.agitationType
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
    
    private func timerFinished() {
        stopTimer()
        isTimerFinished = true
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func startFixingTimer() {
        // Устанавливаем значения по умолчанию для фиксирования
        fixingMinutes = 5
        fixingSeconds = 0
        showFixingTimer = true
    }
    
    func startFixingTimerWithTime(minutes: Int, seconds: Int) {
        // Сбрасываем состояние таймера для фиксирования
        timeRemaining = minutes * 60 + seconds
        totalMinutes = minutes
        totalSeconds = minutes * 60 + seconds
        currentMinute = 1
        isTimerFinished = false
        
        // Устанавливаем режим фиксирования
        let fixerMode = AgitationMode.presets.first { $0.name == String(localized: "agitationFixerName") }
        selectedAgitationMode = fixerMode
        setupAgitation()
        
        showFixingTimer = false
    }
    
    // MARK: - Debug Methods
    
    func enableDebugMode() {
        // Включаем подробное логирование для отладки
        print("🔧 Режим отладки включен")
        print("📊 Текущие настройки:")
        print("   - Режим встряхивания: \(selectedAgitationMode?.name ?? "Не выбран")")
        print("   - Общее время: \(totalMinutes) мин \(totalSeconds % 60) сек")
        print("   - Текущая минута: \(currentMinute)")
        print("   - Время встряхивания: \(agitationTimeRemaining)")
        print("   - В режиме встряхивания: \(isInAgitationPhase)")
    }
} 
