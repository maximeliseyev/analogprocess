import SwiftUI

public struct TimerView: View {
    let timerLabel: String
    let totalMinutes: Int
    let totalSeconds: Int
    
    @StateObject private var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(timerLabel: String, totalMinutes: Int, totalSeconds: Int) {
        self.timerLabel = timerLabel
        self.totalMinutes = totalMinutes
        self.totalSeconds = totalSeconds
        self._viewModel = StateObject(wrappedValue: TimerViewModel(totalMinutes: totalMinutes, totalSeconds: totalSeconds))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    TimerHeaderView(
                        timerLabel: timerLabel,
                        totalMinutes: totalMinutes,
                        totalSeconds: totalSeconds,
                        selectedAgitationMode: viewModel.selectedAgitationMode
                    )
                    
                    TimerProgressView(
                        progress: viewModel.progress,
                        displayMinutes: viewModel.displayMinutes,
                        displaySeconds: viewModel.displaySeconds
                    )
                    
                    AgitationIndicatorView(
                        shouldAgitate: viewModel.shouldAgitate,
                        selectedAgitationMode: viewModel.selectedAgitationMode,
                        isInAgitationPhase: viewModel.isInAgitationPhase,
                        agitationTimeRemaining: viewModel.agitationTimeRemaining,
                        currentMinute: viewModel.currentMinute,
                        currentAgitationPhase: viewModel.currentAgitationPhase
                    )
                    
                    TimerControlsView(
                        isRunning: viewModel.isRunning,
                        onStartPause: viewModel.startPauseTimer,
                        onReset: viewModel.resetTimer
                    )
                    
                    Spacer()
                }
            }
            .navigationTitle(LocalizedStringKey("timer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AgitationSelectionView(
                        selectedMode: Binding(
                            get: { viewModel.selectedAgitationMode ?? AgitationMode.presets[0] },
                            set: { newMode in
                                viewModel.selectAgitationMode(newMode)
                            }
                        )
                    )) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAgitationSelection) {
                AgitationSelectionView(
                    selectedMode: Binding(
                        get: { viewModel.selectedAgitationMode ?? AgitationMode.presets[0] },
                        set: { newMode in
                            viewModel.selectAgitationMode(newMode)
                        }
                    )
                )
            }
            .onAppear {
                viewModel.setupTimer(totalMinutes: totalMinutes, totalSeconds: totalSeconds)
            }
        }
    }
}
