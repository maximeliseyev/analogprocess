import SwiftUI
#if canImport(UIKit)
import UIKit
#endif


// MARK: - Haptics Helper
struct Haptics {
    static func impact(_ intensity: CGFloat = 1.0) {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: intensity)
        #endif
    }
    static func selection() {
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }
    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}



// MARK: - Main Staging View
struct StagingView: View {
    @EnvironmentObject var swiftDataService: SwiftDataService
    @StateObject private var viewModel = StagingViewModel()
    @State private var showingStagePicker = false
    @State private var draggedStage: StagingStage?
    @State private var showingStagingTimer = false
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Intro section
                VStack(spacing: 8) {
                    Text(LocalizedStringKey("stagingIntro"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Stages list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.selectedStages.indices, id: \.self) { index in
                            let stage = viewModel.selectedStages[index]
                            StageRowView(
                                stage: stage,
                                swiftDataService: swiftDataService,
                                onDelete: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.removeStage(at: index)
                                    }
                                },
                                onDuplicate: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.duplicateStage(stage)
                                    }
                                },
                                onUpdate: { updated in
                                    if index < viewModel.selectedStages.count {
                                        viewModel.selectedStages[index] = updated
                                    }
                                }
                            )
                            .opacity(draggedStage?.id == stage.id ? 0.7 : 1.0)
                            .onDrag {
                                self.draggedStage = stage
                                return NSItemProvider(object: stage.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(
                                draggedStage: $draggedStage,
                                stages: $viewModel.selectedStages,
                                currentIndex: index
                            ))
                        }
                        
                        // Add stage button
                        AddStageButton(onTap: {
                            showingStagePicker = true
                        })
                    }
                    .padding(.horizontal)
                }
                
                // Summary section
                if !viewModel.selectedStages.isEmpty {
                    VStack(spacing: 12) {
                        VStack(spacing: 8) {
                            HStack {
                                Text(LocalizedStringKey("totalTime"))
                                    .font(.headline)
                                Spacer()
                                Text(formatDuration(viewModel.getTotalDuration()))
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text(LocalizedStringKey("stagesInProcess"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(viewModel.selectedStages.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        // Cancel button
                        if !viewModel.selectedStages.isEmpty {
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                    Text(LocalizedStringKey("resetStages"))
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.red)
                                .cornerRadius(10)
                            }
                        }
                        
                        // Start button
                        Button(action: {
                            showingStagingTimer = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text(LocalizedStringKey("stagingStartSequential"))
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle(LocalizedStringKey("staging"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingStagePicker) {
            StagePickerView(
                availableStages: viewModel.getAvailableStages(),
                onSelectStage: { stage in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.addStage(stage)
                    }
                    showingStagePicker = false
                },
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $showingStagingTimer) {
            StagingTimerView(stages: viewModel.selectedStages)
        }
        .alert(LocalizedStringKey("stagingResetConfirmation"), isPresented: $showingResetConfirmation) {
            Button(LocalizedStringKey("cancel"), role: .cancel) { }
            Button(LocalizedStringKey("reset"), role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.resetStages()
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
