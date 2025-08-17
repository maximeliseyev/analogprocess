import SwiftUI

struct StageEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var localStage: StagingStage
    let onSave: (StagingStage) -> Void
    
    @State private var minutes: Int
    @State private var seconds: Int
    @State private var selectedAgitationKey: String
    
    // Сохраняем ViewModel для DevelopmentSetup
    @State private var developmentSetupViewModel: DevelopmentSetupViewModel?
    
    init(stage: StagingStage, onSave: @escaping (StagingStage) -> Void) {
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
        self._selectedAgitationKey = State(initialValue: stage.agitationPresetKey ?? defaultKey)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(LocalizedStringKey("stageTime"))) {
                    HStack {
                        Text(LocalizedStringKey("duration"))
                        Spacer()
                        InlineTimePicker(minutes: $minutes, seconds: $seconds)
                    }
                }
                if localStage.type == .develop || localStage.type == .fixer || localStage.type == .bleach {
                    Section(header: Text(LocalizedStringKey("agitation"))) {
                        if localStage.type == .bleach {
                            HStack {
                                Text(LocalizedStringKey("agitationMode"))
                                Spacer()
                                Text(LocalizedStringKey("agitationContinuousName")).foregroundColor(.secondary)
                            }
                        } else {
                            NavigationLink(destination: SimpleAgitationPicker(selectedKey: $selectedAgitationKey)) {
                                HStack {
                                    Text(LocalizedStringKey("agitationMode"))
                                    Spacer()
                                    Text(LocalizedStringKey(selectedAgitationKey))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                if localStage.type == .develop || localStage.type == .fixer {
                    Section(header: Text(LocalizedStringKey("advancedSetup"))) {
                        NavigationLink(destination: DevelopmentSetupView(
                            isFromStageEditor: true, 
                            stageType: localStage.type,
                            viewModel: developmentSetupViewModel
                        )) {
                            Text(LocalizedStringKey(localStage.type == .develop ? "openDevelopmentSetup" : "openFixerSetup"))
                        }
                        .onAppear {
                            // Создаем ViewModel при первом открытии
                            if developmentSetupViewModel == nil {
                                developmentSetupViewModel = DevelopmentSetupViewModel()
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
            // Дополнительно закрываем DevelopmentSetupView, чтобы вернуться к StageEditorSheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(
                    name: Notification.Name("DismissDevelopmentSetupView"),
                    object: nil
                )
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

private struct SimpleAgitationPicker: View {
    @Binding var selectedKey: String
    private let options: [String] = [
        "agitationOrwoName",
        "agitationXtolName",
        "agitationRaeName",
        "agitationFixerName",
        "agitationContinuousName",
        "agitationStillName"
    ]
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            ForEach(options, id: \.self) { key in
                HStack {
                    Text(LocalizedStringKey(key))
                    Spacer()
                    if key == selectedKey { Image(systemName: "checkmark").checkmarkStyle() }
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedKey = key; dismiss() }
            }
        }
        .navigationTitle(LocalizedStringKey("agitationSelection"))
    }
}
