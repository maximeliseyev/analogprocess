//
//  CustomAgitationEditorView.swift
//  AnalogProcess
//
//  Created by Claude on 14.09.2025.
//

import SwiftUI
import SwiftData

struct CustomAgitationEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CustomAgitationViewModel
    @Binding var selectedMode: AgitationMode?
    
    init(selectedMode: Binding<AgitationMode?>) {
        self._selectedMode = selectedMode
        // Временный ViewModel, будет заменен в onAppear
        let tempContainer = try! ModelContainer(for: SwiftDataCustomAgitationMode.self)
        self._viewModel = State(initialValue: CustomAgitationViewModel(modelContext: tempContainer.mainContext))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Name input
                    nameSection
                    
                    // First minute configuration
                    firstMinuteSection
                    
                    // Intermediate minutes configuration  
                    intermediateSection
                    
                    // Last minute toggle and configuration
                    lastMinuteSection
                    
                    // Preview section
                    previewSection
                    
                    // Action buttons
                    actionButtons
                }
                .padding()
            }
            .navigationTitle(viewModel.isEditingMode ? 
                LocalizedStringKey("customAgitationEditTitle") : 
                LocalizedStringKey("customAgitationCreateTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        Task {
                            await viewModel.saveMode()
                            if viewModel.isConfigurationValid && viewModel.saveError == nil {
                                // Возвращаем созданный режим
                                selectedMode = viewModel.getAgitationMode()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isConfigurationValid || viewModel.isSaving)
                }
            }
            .onAppear {
                viewModel = CustomAgitationViewModel(modelContext: modelContext)
            }
        }
        .alert(LocalizedStringKey("validationError"), 
               isPresented: $viewModel.showValidationErrors) {
            Button(LocalizedStringKey("ok")) { }
        } message: {
            VStack(alignment: .leading) {
                ForEach(viewModel.validateConfiguration(), id: \.self) { error in
                    Text(error)
                }
            }
        }
        .alert(LocalizedStringKey("saveError"), 
               isPresented: $viewModel.showSaveError) {
            Button(LocalizedStringKey("ok")) { }
        } message: {
            if let error = viewModel.saveError {
                Text(error.localizedDescription)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil.and.outline")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            Text(LocalizedStringKey("customAgitationDescription"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(LocalizedStringKey("customAgitationName"))
                    .font(.headline)
                Text("*")
                    .foregroundColor(.red)
            }
            
            TextField(LocalizedStringKey("customAgitationNamePlaceholder"), 
                     text: $viewModel.config.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    private var firstMinuteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("customAgitationFirstMinute"))
                .font(.headline)
            
            Text(LocalizedStringKey("customAgitationFirstMinuteDescription"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            AgitationPhaseConfigView(
                config: $viewModel.config.firstMinute,
                title: String(localized: "customAgitationFirstMinute")
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var intermediateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("customAgitationIntermediate"))
                .font(.headline)
            
            Text(LocalizedStringKey("customAgitationIntermediateDescription"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            AgitationPhaseConfigView(
                config: $viewModel.config.intermediate,
                title: String(localized: "customAgitationIntermediate")
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var lastMinuteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(LocalizedStringKey("customAgitationEnableLastMinute"), 
                   isOn: $viewModel.config.hasLastMinuteCustom)
                .font(.headline)
                .onChange(of: viewModel.config.hasLastMinuteCustom) { _, newValue in
                    viewModel.toggleLastMinuteCustom()
                }
            
            if viewModel.config.hasLastMinuteCustom {
                Text(LocalizedStringKey("customAgitationLastMinuteDescription"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let lastMinuteConfig = Binding($viewModel.config.lastMinute) {
                    AgitationPhaseConfigView(
                        config: lastMinuteConfig,
                        title: String(localized: "customAgitationLastMinute")
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizedStringKey("customAgitationPreview"))
                .font(.headline)
            
            if let agitationMode = viewModel.getAgitationMode() {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                        Text(agitationMode.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Text(agitationMode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else {
                Text(LocalizedStringKey("customAgitationPreviewUnavailable"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.saveMode()
                    if viewModel.isConfigurationValid && viewModel.saveError == nil {
                        selectedMode = viewModel.getAgitationMode()
                        dismiss()
                    }
                }
            }) {
                HStack {
                    if viewModel.isSaving {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "checkmark")
                    }
                    Text(viewModel.isEditingMode ? 
                         LocalizedStringKey("customAgitationUpdateButton") : 
                         LocalizedStringKey("customAgitationCreateButton"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isConfigurationValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!viewModel.isConfigurationValid || viewModel.isSaving)
            
            Button(LocalizedStringKey("customAgitationReset")) {
                viewModel.resetConfiguration()
            }
            .foregroundColor(.red)
        }
    }
}

// MARK: - Preview

struct CustomAgitationEditorView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAgitationEditorView(selectedMode: .constant(nil))
    }
}
