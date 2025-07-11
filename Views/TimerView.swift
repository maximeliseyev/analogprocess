//
//  TimerView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//


import SwiftUI

struct TimerView: View {
    let timerLabel: String
    let totalMinutes: Int
    let totalSeconds: Int
    let onClose: () -> Void
    
    @State private var timeRemaining: Int = 0
    @State private var isRunning = false
    @State private var timer: Timer?
    @State private var showingAlert = false
    
    private var totalTime: Int {
        totalMinutes * 60 + totalSeconds
    }
    
    private var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    private var displayMinutes: Int {
        timeRemaining / 60
    }
    
    private var displaySeconds: Int {
        timeRemaining % 60
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Заголовок процесса
                VStack(spacing: 10) {
                    Text(timerLabel)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Время: \(totalMinutes):\(String(format: "%02d", totalSeconds))")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Круговой прогресс-бар
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(timeRemaining <= 30 ? .red : .blue)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    VStack(spacing: 8) {
                        Text("\(displayMinutes):\(String(format: "%02d", displaySeconds))")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(timeRemaining <= 30 ? .red : .primary)
                        
                        if timeRemaining <= 30 && timeRemaining > 0 {
                            Text("Осталось мало времени!")
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .frame(width: 250, height: 250)
                
                // Кнопки управления
                HStack(spacing: 30) {
                    Button(action: startPauseTimer) {
                        HStack {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? "Пауза" : "Старт")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(isRunning ? Color.orange : Color.green)
                        .cornerRadius(25)
                    }
                    
                    Button(action: resetTimer) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Сброс")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.gray)
                        .cornerRadius(25)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        stopTimer()
                        onClose()
                    }
                }
            }
            .onAppear {
                resetTimer()
            }
            .onDisappear {
                stopTimer()
            }
            .alert("Время вышло!", isPresented: $showingAlert) {
                Button("OK") {
                    showingAlert = false
                }
            } message: {
                Text("Проявка завершена для процесса: \(timerLabel)")
            }
        }
    }
    
    private func startPauseTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        guard timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timerFinished()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = totalTime
    }
    
    private func timerFinished() {
        stopTimer()
        showingAlert = true
        
        // Вибрация при завершении
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Можно добавить звуковой сигнал
        // AudioServicesPlaySystemSound(SystemSoundID(1322))
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(
            timerLabel: "push +2",
            totalMinutes: 8,
            totalSeconds: 45,
            onClose: {}
        )
    }
}
