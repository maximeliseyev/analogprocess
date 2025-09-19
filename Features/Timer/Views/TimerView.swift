import SwiftUI

public struct TimerView: View {
    let timerLabel: String
    let totalMinutes: Int
    let totalSeconds: Int
    let selectedAgitationMode: AgitationMode?

    @StateObject private var viewModel: UnifiedTimerViewModel
    @Environment(\.dismiss) private var dismiss

    public init(timerLabel: String, totalMinutes: Int, totalSeconds: Int, selectedAgitationMode: AgitationMode? = nil) {
        self.timerLabel = timerLabel
        self.totalMinutes = totalMinutes
        self.totalSeconds = totalSeconds
        self.selectedAgitationMode = selectedAgitationMode
        let duration = TimeInterval(totalMinutes * 60 + totalSeconds)
        let viewModel = UnifiedTimerViewModel(duration: duration, name: timerLabel)
        if let agitationMode = selectedAgitationMode {
            viewModel.selectedAgitationMode = agitationMode
        }
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    TimerHeaderView(
                        timerLabel: LocalizedStringKey(timerLabel),
                        totalMinutes: totalMinutes,
                        totalSeconds: totalSeconds,
                        selectedAgitationMode: viewModel.selectedAgitationMode
                    )
                    
                    TimerProgressView(
                        progress: viewModel.progress,
                        displayMinutes: viewModel.displayMinutes,
                        displaySeconds: viewModel.displaySeconds,
                        isInAgitationPhase: viewModel.isInAgitationPhase,
                        agitationTimeRemaining: viewModel.agitationTimeRemaining,
                        isRunning: viewModel.isRunning
                    )
                    
                    AgitationIndicatorView(
                        shouldAgitate: viewModel.shouldAgitate,
                        selectedAgitationMode: viewModel.selectedAgitationMode,
                        isInAgitationPhase: viewModel.isInAgitationPhase,
                        agitationTimeRemaining: viewModel.agitationTimeRemaining,
                        currentMinute: viewModel.currentMinute,
                        currentAgitationPhase: viewModel.currentAgitationPhase
                    )
                    
                    if viewModel.isTimerFinished {
                        VStack(spacing: 16) {
                            Text(LocalizedStringKey("developmentCompleted"))
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Text(LocalizedStringKey("stagingFinish"))
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(.green)
                                .cornerRadius(10)
                            }
                        }
                    } else {
                        TimerControlsView(
                            isRunning: viewModel.isRunning,
                            onStartPause: viewModel.startPauseTimer,
                            onReset: viewModel.resetTimer
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle(LocalizedStringKey("timer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
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
                            .foregroundColor(.primary)
                            .font(.title2)
                    }
                }
            })
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
            .sheet(isPresented: $viewModel.showManualTimeInput) {
                ManualTimeInputView(
                    minutes: Binding(
                        get: { viewModel.currentTotalMinutes },
                        set: { viewModel.currentTotalMinutes = $0 }
                    ),
                    seconds: Binding(
                        get: { viewModel.currentTotalSeconds },
                        set: { viewModel.currentTotalSeconds = $0 }
                    ),
                    onApply: {
                        viewModel.updateTimerTime(
                            minutes: viewModel.currentTotalMinutes,
                            seconds: viewModel.currentTotalSeconds
                        )
                    },
                    onCancel: {
                        viewModel.showManualTimeInput = false
                    },
                    title: "setTimeManually"
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $viewModel.showFixingTimer) {
                ManualTimeInputView(
                    minutes: Binding(
                        get: { viewModel.fixingMinutes },
                        set: { viewModel.fixingMinutes = $0 }
                    ),
                    seconds: Binding(
                        get: { viewModel.fixingSeconds },
                        set: { viewModel.fixingSeconds = $0 }
                    ),
                    onApply: {
                        viewModel.startFixingTimerWithTime(
                            minutes: viewModel.fixingMinutes,
                            seconds: viewModel.fixingSeconds
                        )
                    },
                    onCancel: {
                        viewModel.showFixingTimer = false
                    },
                    title: "fixingTime"
                )
                .presentationDetents([.medium])
            }
        }
    }
}

// MARK: - Previews

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Основной превью - таймер в состоянии покоя
            TimerView(
                timerLabel: "Kodak Tri-X 400 + XTOL 1+1",
                totalMinutes: 8,
                totalSeconds: 30
            )
            .previewDisplayName("Timer - Idle State")
            
            // Таймер во время работы
            TimerView(
                timerLabel: "Ilford HP5+ + HC-110 B",
                totalMinutes: 6,
                totalSeconds: 45
            )
            .previewDisplayName("Timer - Running State")
            
            // Длинный таймер
            TimerView(
                timerLabel: "Foma 400 + Rodinal 1+50",
                totalMinutes: 15,
                totalSeconds: 0
            )
            .previewDisplayName("Timer - Long Development")
            
            // Короткий таймер
            TimerView(
                timerLabel: "Kodak T-Max 100 + D-76",
                totalMinutes: 2,
                totalSeconds: 30
            )
            .previewDisplayName("Timer - Short Development")
        }
        .preferredColorScheme(.dark)
        .previewLayout(.device)
    }
}
