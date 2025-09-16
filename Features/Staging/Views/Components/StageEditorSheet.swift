import SwiftUI

struct StageEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let swiftDataService: SwiftDataService
    
    @State private var localStage: StagingStage
    let onSave: (StagingStage) -> Void
    
    private var minutes: Int {
        Int(localStage.duration) / 60
    }

    private var seconds: Int {
        Int(localStage.duration) % 60
    }
    @State private var selectedAgitationKey: String
    @State private var showingManualTimePicker = false

    // For AgitationSelectionView
    @State private var agitationMode: AgitationMode
    
    private let keyToType: [String: AgitationModeType] = [
        "agitationOrwoName": .orwo,
        "agitationXtolName": .xtol,
        "agitationRaeName": .rae,
        "agitationFixerName": .fixer,
        "agitationContinuousName": .continuous,
        "agitationStillName": .still
    ]
    
    private var typeToKey: [AgitationModeType: String] {
        Dictionary(uniqueKeysWithValues: keyToType.map { ($1, $0) })
    }
    
    init(swiftDataService: SwiftDataService, stage: StagingStage, onSave: @escaping (StagingStage) -> Void) {
        self.swiftDataService = swiftDataService
        self._localStage = State(initialValue: stage)
        self.onSave = onSave
        
        let defaultKey: String = {
            switch stage.type {
            case .bleach: return "agitationContinuousName"
            case .fixer: return "agitationFixerName"
            default: return "agitationXtolName"
            }
        }()
        let key = stage.agitationPresetKey ?? defaultKey
        self._selectedAgitationKey = State(initialValue: key)
        
        let type = keyToType[key]
        let mode = AgitationMode.presets.first { $0.type == type } ?? AgitationMode.presets.first { $0.type == .xtol } ?? AgitationMode.presets[0]
        self._agitationMode = State(initialValue: mode)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                if localStage.type == .develop {
                    // Preset time setup section for development
                    Section(header: Text(LocalizedStringKey("setupTimeByPreset"))) {
                        NavigationLink(destination: DevelopmentSetupView(
                            viewModel: DevelopmentSetupViewModel<SwiftDataService>(dataService: swiftDataService),
                            isFromStageEditor: true,
                            stageType: localStage.type
                        )) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey("setupTimeByPreset"))
                                        .font(.body)
                                    Text(LocalizedStringKey("fromDatabase"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }

                    // Custom time setup section
                    Section(header: Text(LocalizedStringKey("customTime"))) {
                        Button(action: {
                            showingManualTimePicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey("manualInput"))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(LocalizedStringKey("setTimeManually"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(formatDuration(TimeInterval(minutes * 60 + seconds)))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    Text(LocalizedStringKey("tapToChangeTime"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 4)
                    }

                    Section(header: Text(LocalizedStringKey("agitation"))) {
                        NavigationLink(destination: AgitationSelectionView(selectedMode: $agitationMode)) {
                            HStack {
                                Text(LocalizedStringKey("agitationMode"))
                                Spacer()
                                Text(agitationMode.name)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else if localStage.type == .fixer {
                    // Preset time setup section for fixer
                    Section(header: Text(LocalizedStringKey("setupTimeByPreset"))) {
                        NavigationLink(destination: DevelopmentSetupView(
                            viewModel: DevelopmentSetupViewModel<SwiftDataService>(dataService: swiftDataService),
                            isFromStageEditor: true,
                            stageType: localStage.type
                        )) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey("openFixerSetup"))
                                        .font(.body)
                                    Text(LocalizedStringKey("fromDatabase"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    }

                    // Custom time setup section for fixer
                    Section(header: Text(LocalizedStringKey("customTime"))) {
                        Button(action: {
                            showingManualTimePicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey("manualInput"))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(LocalizedStringKey("setTimeManually"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(formatDuration(TimeInterval(minutes * 60 + seconds)))
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    Text(LocalizedStringKey("tapToChangeTime"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 4)
                    }

                    Section(header: Text(LocalizedStringKey("agitation"))) {
                        NavigationLink(destination: AgitationSelectionView(selectedMode: $agitationMode)) {
                            HStack {
                                Text(LocalizedStringKey("agitationMode"))
                                Spacer()
                                Text(agitationMode.name)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    // Fallback for other stage types
                    Section(header: Text(LocalizedStringKey("stageTime"))) {
                        HStack {
                            Text(LocalizedStringKey("duration"))
                            Spacer()
                            InlineTimePicker(
                                minutes: Binding(
                                    get: { self.minutes },
                                    set: { newValue in
                                        let newDuration = TimeInterval(newValue * 60 + self.seconds)
                                        self.localStage.duration = newDuration
                                        print("🔄 minutes binding: Updated duration to \(newDuration)")
                                    }
                                ),
                                seconds: Binding(
                                    get: { self.seconds },
                                    set: { newValue in
                                        let newDuration = TimeInterval(self.minutes * 60 + newValue)
                                        self.localStage.duration = newDuration
                                        print("🔄 seconds binding: Updated duration to \(newDuration)")
                                    }
                                )
                            )
                        }
                    }
                    if localStage.type == .bleach {
                        Section(header: Text(LocalizedStringKey("agitation"))) {
                            HStack {
                                Text(LocalizedStringKey("agitationMode"))
                                Spacer()
                                Text(LocalizedStringKey("agitationContinuousName")).foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            // Save button at bottom
            Button(action: {
                // duration уже обновлена через binding'и
                localStage.agitationPresetKey = selectedAgitationKey
                onSave(localStage)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark")
                    Text(LocalizedStringKey("save"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(Text(LocalizedStringKey(localStage.name)))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DevelopmentCalculatedTime"))) { output in
                print("📥 StageEditorSheet: Received DevelopmentCalculatedTime notification")
                if let secondsVal = output.userInfo?["seconds"] as? Int {
                    let newMinutes = secondsVal / 60
                    let newSeconds = secondsVal % 60
                    print("🔄 StageEditorSheet: Updating time from \(minutes):\(String(format: "%02d", seconds)) to \(newMinutes):\(String(format: "%02d", newSeconds))")

                    // Обновляем localStage.duration напрямую
                    DispatchQueue.main.async {
                        self.localStage.duration = TimeInterval(secondsVal)
                        print("✅ StageEditorSheet: Updated duration to \(self.localStage.duration) seconds (now shows \(self.minutes):\(String(format: "%02d", self.seconds)))")
                    }
                } else {
                    print("❌ StageEditorSheet: No seconds found in notification userInfo")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DismissCalculatorView"))) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    NotificationCenter.default.post(
                        name: Notification.Name("DismissDevelopmentSetupView"),
                        object: nil
                    )
                }
            }
            .onChange(of: agitationMode) { oldMode, newMode in
                if let newKey = typeToKey[newMode.type] {
                    selectedAgitationKey = newKey
                }
            }
            .sheet(isPresented: $showingManualTimePicker) {
                ManualTimeInputView(
                    minutes: Binding(
                        get: { self.minutes },
                        set: { newValue in
                            let newDuration = TimeInterval(newValue * 60 + self.seconds)
                            self.localStage.duration = newDuration
                            print("🔄 ManualTimeInputView minutes: Updated duration to \(newDuration)")
                        }
                    ),
                    seconds: Binding(
                        get: { self.seconds },
                        set: { newValue in
                            let newDuration = TimeInterval(self.minutes * 60 + newValue)
                            self.localStage.duration = newDuration
                            print("🔄 ManualTimeInputView seconds: Updated duration to \(newDuration)")
                        }
                    ),
                    onApply: {
                        showingManualTimePicker = false
                    },
                    onCancel: {
                        showingManualTimePicker = false
                    },
                    title: "setTimeManually"
                )
                .presentationDetents([.medium])
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct InlineTimePicker: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("min")
                    .captionTextStyle()
                Picker("", selection: $minutes) { ForEach(0...59, id: \.self) { Text("\($0)") } }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 60)
                    .clipped()
            }
            
            Text(":")
                .monospacedTitleStyle()
                .padding(.top, 8)
            
            VStack(spacing: 4) {
                Text("sec")
                    .captionTextStyle()
                Picker("", selection: $seconds) { ForEach(0...59, id: \.self) { Text(String(format: "%02d", $0)) } }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 60)
                    .clipped()
            }
        }
    }
}
