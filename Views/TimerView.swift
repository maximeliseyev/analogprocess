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
    @State private var showAgitationSelection = true
    @State private var selectedAgitationMode: AgitationMode?
    
    // Ажитация
    @State private var currentMinute: Int = 1
    @State private var shouldAgitate = false
    @State private var agitationTimeRemaining = 0
    @State private var isInAgitationPhase = false
    @State private var currentAgitationPhase: AgitationMode.PhaseAgitationType?
    
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
                    
                    if let mode = selectedAgitationMode {
                        Text(mode.name)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 20)
                
                // Индикатор ажитации
                if shouldAgitate && selectedAgitationMode != nil {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(isInAgitationPhase ? .orange : .blue)
                                .font(.title2)
                            
                            Text(isInAgitationPhase ? "АЖИТАЦИЯ" : "ПОКОЙ")
                                .font(.headline)
                                .foregroundColor(isInAgitationPhase ? .orange : .blue)
                                .fontWeight(.bold)
                            
                            if agitationTimeRemaining > 0 {
                                Text("(\(agitationTimeRemaining)с)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isInAgitationPhase ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                        .cornerRadius(20)
                        
                        // Показываем текущую минуту и режим ажитации
                        VStack(spacing: 4) {
                            Text("Минута \(currentMinute)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if let phase = currentAgitationPhase {
                                Text(getPhaseDescription(phase))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
                
                // Круговой прогресс-бар
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(progress))
                        .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    
                    VStack(spacing: 8) {
                        Text("\(displayMinutes):\(String(format: "%02d", displaySeconds))")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
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
            .sheet(isPresented: $showAgitationSelection) {
                AgitationSelectionView { mode in
                    selectedAgitationMode = mode
                    showAgitationSelection = false
                    setupAgitation()
                }
            }
        }
    }
    
    private func getPhaseDescription(_ phase: AgitationMode.PhaseAgitationType) -> String {
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
                updateCurrentMinute()
                updateAgitation()
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
        currentMinute = 1
        setupAgitation()
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
