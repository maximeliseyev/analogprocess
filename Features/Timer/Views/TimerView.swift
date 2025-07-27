import SwiftUI

public struct TimerView: View {
    let timerLabel: String
    let totalMinutes: Int
    let totalSeconds: Int
    let onClose: () -> Void
    
    @StateObject private var viewModel: TimerViewModel
    
    public init(timerLabel: String, totalMinutes: Int, totalSeconds: Int, onClose: @escaping () -> Void) {
        self.timerLabel = timerLabel
        self.totalMinutes = totalMinutes
        self.totalSeconds = totalSeconds
        self.onClose = onClose
        self._viewModel = StateObject(wrappedValue: TimerViewModel(totalMinutes: totalMinutes, totalSeconds: totalSeconds))
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                TimerHeaderView(
                    timerLabel: timerLabel,
                    totalMinutes: totalMinutes,
                    totalSeconds: totalSeconds,
                    selectedAgitationMode: viewModel.selectedAgitationMode
                )
                
                AgitationIndicatorView(
                    shouldAgitate: viewModel.shouldAgitate,
                    selectedAgitationMode: viewModel.selectedAgitationMode,
                    isInAgitationPhase: viewModel.isInAgitationPhase,
                    agitationTimeRemaining: viewModel.agitationTimeRemaining,
                    currentMinute: viewModel.currentMinute,
                    currentAgitationPhase: viewModel.currentAgitationPhase
                )
                
                TimerProgressView(
                    progress: viewModel.progress,
                    displayMinutes: viewModel.displayMinutes,
                    displaySeconds: viewModel.displaySeconds
                )
                
                TimerControlsView(
                    isRunning: viewModel.isRunning,
                    onStartPause: viewModel.startPauseTimer,
                    onReset: viewModel.resetTimer
                )
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.resetTimer()
            }
            .onDisappear {
                viewModel.stopTimer()
            }
            .alert(LocalizedStringKey("timeUp"), isPresented: $viewModel.showingAlert) {
                Button("OK") {
                    viewModel.showingAlert = false
                }
            } message: {
                Text("\(LocalizedStringKey("developmentCompleteForProcess")) \(timerLabel)")
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
