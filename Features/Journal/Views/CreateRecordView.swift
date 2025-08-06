//
//  CreateRecordView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CreateRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateRecordViewModel()
    
    // Параметры для предзаполнения из калькулятора
    let prefillData: JournalRecord?
    let isEditing: Bool
    let onUpdate: ((JournalRecord) -> Void)?
    
    init(prefillData: JournalRecord? = nil, isEditing: Bool = false, onUpdate: ((JournalRecord) -> Void)? = nil) {
        self.prefillData = prefillData
        self.isEditing = isEditing
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            KeyboardAwareView {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(LocalizedStringKey("journal_record_basic_info"))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                TextField(LocalizedStringKey("journal_record_name"), text: $viewModel.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField(LocalizedStringKey("journal_record_film"), text: $viewModel.filmName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField(LocalizedStringKey("journal_record_developer"), text: $viewModel.developerName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    viewModel.showISOPicker = true
                                }) {
                                    HStack {
                                        Text("\(viewModel.iso)")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .sheet(isPresented: $viewModel.showISOPicker) {
                                    ISOPickerView(
                                        iso: $viewModel.iso,
                                        onDismiss: { viewModel.showISOPicker = false },
                                        availableISOs: viewModel.getAvailableISOs()
                                    )
                                }
                                
                                TextField(LocalizedStringKey("journal_record_process"), text: $viewModel.process)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField(LocalizedStringKey("journal_record_dilution"), text: $viewModel.dilution)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                HStack {
                                    TextField("", value: $viewModel.temperature, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                    Text("\(NSLocalizedString("journal_record_temperature", comment: "")) \(NSLocalizedString("degreesCelsius", comment: ""))")
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack {
                                    TextField("", value: $viewModel.minutes, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .onChange(of: viewModel.minutes) { oldValue, newValue in
                                            if newValue < 0 {
                                                viewModel.minutes = 0
                                            }
                                        }
                                    Text(LocalizedStringKey("min"))
                                        .foregroundColor(.secondary)
                                    TextField("", value: $viewModel.seconds, format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .onChange(of: viewModel.seconds) { oldValue, newValue in
                                            if newValue > 59 {
                                                viewModel.seconds = 59
                                            } else if newValue < 0 {
                                                viewModel.seconds = 0
                                            }
                                        }
                                    Text(LocalizedStringKey("sec"))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text(LocalizedStringKey("journal_record_comment"))
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField(LocalizedStringKey("journal_record_comment_placeholder"), text: $viewModel.comment, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .lineLimit(3...6)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            DatePicker(
                                LocalizedStringKey("journal_record_date"),
                                selection: $viewModel.date,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                        .padding()
                    }
                    .navigationTitle(isEditing ? LocalizedStringKey("edit_record") : LocalizedStringKey("journal_create_record"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(LocalizedStringKey("cancel")) {
                                dismiss()
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(LocalizedStringKey("save")) {
                                if isEditing {
                                    let updatedRecord = viewModel.createJournalRecord()
                                    onUpdate?(updatedRecord)
                                } else {
                                    viewModel.saveRecord()
                                }
                                dismiss()
                            }
                            .disabled(!viewModel.isValid)
                        }
                    }
                    .onAppear {
                        if let prefillData = prefillData {
                            viewModel.prefill(with: prefillData)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CreateRecordView()
} 
