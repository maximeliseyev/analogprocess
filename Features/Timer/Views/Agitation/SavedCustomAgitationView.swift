import SwiftUI
import SwiftData

struct SavedCustomAgitationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CustomAgitationViewModel
    @Binding var selectedMode: AgitationMode?
    @State private var showingEditor = false
    @State private var showingDeleteAlert = false
    @State private var modeToDelete: SwiftDataCustomAgitationMode?
    
    init(selectedMode: Binding<AgitationMode?>) {
        self._selectedMode = selectedMode
        // Временный ViewModel, будет заменен в onAppear
        let tempContainer = try! ModelContainer(for: SwiftDataCustomAgitationMode.self)
        self._viewModel = State(initialValue: CustomAgitationViewModel(modelContext: tempContainer.mainContext))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.savedModes.isEmpty {
                    emptyStateView
                } else {
                    savedModesList
                }
            }
            .navigationTitle(LocalizedStringKey("savedCustomAgitationModes"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("close")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("createNew")) {
                        viewModel.resetConfiguration()
                        showingEditor = true
                    }
                }
            }
            .onAppear {
                viewModel = CustomAgitationViewModel(modelContext: modelContext)
            }
            .refreshable {
                // Перезагрузка данных при pull-to-refresh
                viewModel = CustomAgitationViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showingEditor) {
            CustomAgitationEditorView(selectedMode: $selectedMode)
        }
        .alert(LocalizedStringKey("deleteConfirmation"), 
               isPresented: $showingDeleteAlert) {
            Button(LocalizedStringKey("delete"), role: .destructive) {
                if let mode = modeToDelete {
                    viewModel.deleteMode(mode)
                    modeToDelete = nil
                }
            }
            Button(LocalizedStringKey("cancel"), role: .cancel) {
                modeToDelete = nil
            }
        } message: {
            if let mode = modeToDelete {
                Text(String(format: String(localized: "deleteCustomModeMessage"), mode.name))
            }
        }
    }
    
    // MARK: - View Components
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "waveform.path.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(LocalizedStringKey("noCustomAgitationModes"))
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(LocalizedStringKey("noCustomAgitationModesDescription"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingEditor = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text(LocalizedStringKey("createFirstCustomMode"))
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private var savedModesList: some View {
        List {
            ForEach(viewModel.savedModes, id: \.id) { mode in
                SavedAgitationModeRow(
                    mode: mode,
                    onSelect: {
                        selectedMode = mode.toAgitationMode()
                        dismiss()
                    },
                    onEdit: {
                        viewModel.loadModeForEditing(mode)
                        showingEditor = true
                    },
                    onDelete: {
                        modeToDelete = mode
                        showingDeleteAlert = true
                    }
                )
            }
            .onDelete(perform: deleteModes)
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Actions
    
    private func deleteModes(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteMode(viewModel.savedModes[index])
        }
    }
}

// MARK: - Row Component

struct SavedAgitationModeRow: View {
    let mode: SwiftDataCustomAgitationMode
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(formatDate(mode.updatedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Configuration preview
            VStack(alignment: .leading, spacing: 8) {
                configurationRow(
                    title: String(localized: "customAgitationFirstMinute"),
                    type: mode.firstMinuteAgitationType,
                    agitation: mode.firstMinuteAgitationSeconds,
                    rest: mode.firstMinuteRestSeconds,
                    custom: mode.firstMinuteCustomDescription
                )
                
                configurationRow(
                    title: String(localized: "customAgitationIntermediate"),
                    type: mode.intermediateAgitationType,
                    agitation: mode.intermediateAgitationSeconds,
                    rest: mode.intermediateRestSeconds,
                    custom: mode.intermediateCustomDescription
                )
                
                if mode.hasLastMinuteCustom {
                    configurationRow(
                        title: String(localized: "customAgitationLastMinute"),
                        type: mode.lastMinuteAgitationType ?? "still",
                        agitation: mode.lastMinuteAgitationSeconds,
                        rest: mode.lastMinuteRestSeconds,
                        custom: mode.lastMinuteCustomDescription
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Select button
            Button(action: onSelect) {
                HStack {
                    Image(systemName: "checkmark.circle")
                    Text(LocalizedStringKey("selectThisMode"))
                        .fontWeight(.medium)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Helper Views
    
    private func configurationRow(
        title: String,
        type: String,
        agitation: Int,
        rest: Int,
        custom: String?
    ) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            Image(systemName: iconForType(type))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(descriptionForType(type, agitation: agitation, rest: rest, custom: custom))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "continuous": return "arrow.clockwise"
        case "still": return "pause"
        case "cycle": return "repeat"
        case "periodic": return "timer"
        case "custom": return "text.alignleft"
        default: return "questionmark"
        }
    }
    
    private func descriptionForType(
        _ type: String,
        agitation: Int,
        rest: Int,
        custom: String?
    ) -> String {
        switch type {
        case "continuous":
            return String(localized: "agitationContinuous")
        case "still":
            return String(localized: "agitationStill")
        case "cycle":
            return String(format: String(localized: "agitationCycleFormat"), "\(agitation)", "\(rest)")
        case "periodic":
            return String(format: String(localized: "agitationPeriodicFormat"), "\(agitation)")
        case "custom":
            return custom ?? String(localized: "agitationCustom")
        default:
            return type
        }
    }
}

// MARK: - Preview

struct SavedCustomAgitationView_Previews: PreviewProvider {
    static var previews: some View {
        SavedCustomAgitationView(selectedMode: .constant(nil))
    }
}
