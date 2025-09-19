//
//  StagingTimerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct StagingTimerView: View {
    let stages: [StagingStage]

    @StateObject private var viewModel: UnifiedTimerViewModel
    @Environment(\.dismiss) private var dismiss

    init(stages: [StagingStage]) {
        self.stages = stages
        self._viewModel = StateObject(wrappedValue: UnifiedTimerViewModel(stagingStages: stages))
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        TimerHeaderView(
                            timerLabel: LocalizedStringKey(viewModel.currentStage?.name ?? ""),
                            totalMinutes: Int(viewModel.currentStage?.duration ?? 0) / 60,
                            totalSeconds: Int(viewModel.currentStage?.duration ?? 0) % 60,
                            selectedAgitationMode: viewModel.selectedAgitationMode
                        )
                        
                        Text(String(format: NSLocalizedString("stagingStageXofY", comment: ""), "\(viewModel.currentStageIndex + 1)", "\(stages.count)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
                            Text(LocalizedStringKey("stagingStageComplete"))
                                .font(.headline)
                                .foregroundColor(.green)
                            
                            if viewModel.hasNextStage {
                                Button(action: {
                                    viewModel.startNextStage()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.right")
                                        Text(LocalizedStringKey("stagingGoToNextStage"))
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(.blue)
                                    .cornerRadius(10)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Text(LocalizedStringKey("stagingAllStagesComplete"))
                                        .font(.headline)
                                        .foregroundColor(.green)
                                    
                                    Button(action: {
                                        dismiss()
                                    }) {
                                        Text(LocalizedStringKey("stagingFinish"))
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(.green)
                                            .cornerRadius(10)
                                    }
                                }
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
            .navigationTitle(LocalizedStringKey("stagingSequentialStages"))
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
        }
    }
}

#Preview {
    StagingTimerView(stages: StagingStage.defaultStages)
}
