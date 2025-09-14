import SwiftUI

struct StageEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let swiftDataService: SwiftDataService
    
    @State private var localStage: StagingStage
    let onSave: (StagingStage) -> Void
    
    @State private var minutes: Int
    @State private var seconds: Int
    @State private var selectedAgitationKey: String
    
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
        let totalSeconds = Int(stage.duration)
        self._minutes = State(initialValue: totalSeconds / 60)
        self._seconds = State(initialValue: totalSeconds % 60)
        
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
            Form {
                if localStage.type == .develop || localStage.type == .fixer {
                    Section(header: Text(LocalizedStringKey("timeSetup"))) {
                        NavigationLink(destination: DevelopmentSetupView(
                            viewModel: DevelopmentSetupViewModel<SwiftDataService>(dataService: swiftDataService),
                            isFromStageEditor: true,
                            stageType: localStage.type
                        )) {
                            Text(LocalizedStringKey("setupTimeByPreset"))
                        }
                        
                        HStack {
                            Text(LocalizedStringKey("customTime"))
                            Spacer()
                            InlineTimePicker(minutes: $minutes, seconds: $seconds)
                        }
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
                            InlineTimePicker(minutes: $minutes, seconds: $seconds)
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
            .navigationTitle(Text(LocalizedStringKey(localStage.name)))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        localStage.duration = TimeInterval(minutes * 60 + seconds)
                        localStage.agitationPresetKey = selectedAgitationKey
                        onSave(localStage)
                        dismiss()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DevelopmentCalculatedTime"))) { output in
                if let secondsVal = output.userInfo?["seconds"] as? Int {
                    minutes = secondsVal / 60
                    seconds = secondsVal % 60
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
        }
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
