import SwiftUI

struct TimerView: View {
    let timerLabel: String
    let totalMinutes: Int
    let totalSeconds: Int
    let onClose: () -> Void
    
    @StateObject private var viewModel: TimerViewModel
    
    init(timerLabel: String, totalMinutes: Int, totalSeconds: Int, onClose: @escaping () -> Void) {
        self.timerLabel = timerLabel
        self.totalMinutes = totalMinutes
        self.totalSeconds = totalSeconds
        self.onClose = onClose
        self._viewModel = StateObject(wrappedValue: TimerViewModel(totalMinutes: totalMinutes, totalSeconds: totalSeconds))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                // Заголовок процесса
                TimerHeaderView(
                    timerLabel: timerLabel,
                    totalMinutes: totalMinutes,
                    totalSeconds: totalSeconds,
                    selectedAgitationMode: viewModel.selectedAgitationMode
                )
                
                // Индикатор ажитации
                AgitationIndicatorView(
                    shouldAgitate: viewModel.shouldAgitate,
                    selectedAgitationMode: viewModel.selectedAgitationMode,
                    isInAgitationPhase: viewModel.isInAgitationPhase,
                    agitationTimeRemaining: viewModel.agitationTimeRemaining,
                    currentMinute: viewModel.currentMinute,
                    currentAgitationPhase: viewModel.currentAgitationPhase
                )
                
                // Круговой прогресс-бар
                TimerProgressView(
                    progress: viewModel.progress,
                    displayMinutes: viewModel.displayMinutes,
                    displaySeconds: viewModel.displaySeconds
                )
                
                // Кнопки управления
                TimerControlsView(
                    isRunning: viewModel.isRunning,
                    onStartPause: viewModel.startPauseTimer,
                    onReset: viewModel.resetTimer
                )
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        viewModel.stopTimer()
                        onClose()
                    }
                }
            }
            .onAppear {
                viewModel.resetTimer()
            }
            .onDisappear {
                viewModel.stopTimer()
            }
            .alert("Время вышло!", isPresented: $viewModel.showingAlert) {
                Button("OK") {
                    viewModel.showingAlert = false
                }
            } message: {
                Text("Проявка завершена для процесса: \(timerLabel)")
            }
            .sheet(isPresented: $viewModel.showAgitationSelection) {
                AgitationSelectionView { mode in
                    if let mode = mode {
                        viewModel.selectAgitationMode(mode)
                    }
                }
            }
        }
    }
}
