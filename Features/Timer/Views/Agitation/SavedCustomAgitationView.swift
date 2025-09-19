import SwiftUI
import SwiftData

struct SavedCustomAgitationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CustomAgitationViewModel
    @Binding var selectedMode: AgitationMode?
    @State private var showingEditor = false
    @State private var showingDeleteAlert = false
    @State private var modeToDelete: AgitationMode?

    init(selectedMode: Binding<AgitationMode?>) {
        self._selectedMode = selectedMode
        // Временный ViewModel, будет заменен в onAppear
        let tempContainer = try! ModelContainer(for: AgitationModeData.self)
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
                        selectedMode = mode
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
    let mode: AgitationMode
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

                    Text(mode.isCustom ? String(localized: "customMode") : String(localized: "systemMode"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if mode.isCustom {
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
            }

            // Simple description for the new system
            Text(mode.localizedName)
                .font(.subheadline)
                .foregroundColor(.secondary)
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
}

// MARK: - Preview

struct SavedCustomAgitationView_Previews: PreviewProvider {
    static var previews: some View {
        SavedCustomAgitationView(selectedMode: .constant(nil))
    }
}
