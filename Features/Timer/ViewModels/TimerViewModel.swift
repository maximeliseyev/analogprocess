//
//  TimerViewModel.swift
//  FilmClaculator
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
    
    // Ажитация
    @Published var currentMinute: Int = 1
    @Published var shouldAgitate = false
    @Published var agitationTimeRemaining = 0
    @Published var isInAgitationPhase = false
    @Published var currentAgitationPhase: AgitationMode.PhaseAgitationType?
    
    private var timer: Timer?
    private let totalMinutes: Int
    private let totalSeconds: Int
    
    var totalTime: Int {
        totalMinutes * 60 + totalSeconds
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
    
    func getPhaseDescription(_ phase: AgitationMode.PhaseAgitationType) -> String {
        switch phase {
        case .continuous:
            return "Непрерывная ажитация"
        case .cycle(let agitation, let rest):
            return "\(agitation)с ажитации / \(rest)с покоя"
        case .periodic(let interval):
            return "Каждые \(interval)с"
        case .custom(let description):
            return description
        }
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        guard timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
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
        currentAgitationPhase = mode.getAgitationForMinute(currentMinute, totalMinutes: totalMinutes)
        
        // Настраиваем начальную ажитацию в зависимости от типа
        if let phase = currentAgitationPhase {
            switch phase {
            case .continuous:
                isInAgitationPhase = true
                agitationTimeRemaining = 0 // Бесконечная ажитация
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
        
        // Обновляем текущую фазу ажитации
        let newPhase = mode.getAgitationForMinute(currentMinute, totalMinutes: totalMinutes)
        if newPhase != currentAgitationPhase {
            currentAgitationPhase = newPhase
            setupAgitation()
        }
        
        guard let phase = currentAgitationPhase else { return }
        
        switch phase {
        case .continuous:
            // Непрерывная ажитация - ничего не делаем
            break
            
        case .cycle(let agitation, let rest):
            if agitationTimeRemaining > 0 {
                agitationTimeRemaining -= 1
            } else {
                // Переключаем фазу
                if isInAgitationPhase {
                    // Переходим к покою
                    isInAgitationPhase = false
                    agitationTimeRemaining = rest
                } else {
                    // Переходим к ажитации
                    isInAgitationPhase = true
                    agitationTimeRemaining = agitation
                }
                
                // Тактильная обратная связь
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            
        case .periodic(let interval):
            if agitationTimeRemaining > 0 {
                agitationTimeRemaining -= 1
            } else {
                // Сбрасываем таймер для следующего цикла
                agitationTimeRemaining = interval
                
                // Тактильная обратная связь
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
            
        case .custom:
            // Для кастомных режимов просто показываем информацию
            break
        }
    }
    
    private func timerFinished() {
        stopTimer()
        showingAlert = true
        
        // Вибрация при завершении
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
} 