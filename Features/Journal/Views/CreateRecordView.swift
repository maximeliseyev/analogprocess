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
    
    init(prefillData: JournalRecord? = nil) {
        self.prefillData = prefillData
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(LocalizedStringKey("journal_record_basic_info"))) {
                    TextField(LocalizedStringKey("journal_record_name"), text: $viewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField(LocalizedStringKey("journal_record_film"), text: $viewModel.filmName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField(LocalizedStringKey("journal_record_developer"), text: $viewModel.developerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        TextField("", value: $viewModel.iso, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Text("ISO / EI")
                            .foregroundColor(.secondary)
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
                
                Section(header: Text(LocalizedStringKey("journal_record_comment"))) {
                    TextField(LocalizedStringKey("journal_record_comment_placeholder"), text: $viewModel.comment, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section(header: Text(LocalizedStringKey("journal_record_date"))) {
                    DatePicker(
                        LocalizedStringKey("journal_record_date"),
                        selection: $viewModel.date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .navigationTitle(LocalizedStringKey("journal_create_record"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        viewModel.saveRecord()
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

// MARK: - ViewModel

@MainActor
class CreateRecordViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var filmName: String = ""
    @Published var developerName: String = ""
    @Published var iso: Int32 = 100
    @Published var dilution: String = ""
    @Published var temperature: Double = 20.0
    @Published var process: String = ""
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    @Published var comment: String = ""
    @Published var date: Date = Date()
    
    private let coreDataService = CoreDataService.shared
    
    var isValid: Bool {
        !filmName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !developerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Конвертация времени в секунды
    private var totalSeconds: Int {
        return minutes * 60 + seconds
    }
    
    func prefill(with record: JournalRecord) {
        name = record.name ?? ""
        filmName = record.filmName ?? ""
        developerName = record.developerName ?? ""
        iso = record.iso ?? 100
        process = record.process ?? "push +1"
        dilution = record.dilution ?? ""
        temperature = record.temperature ?? 20.0
        
        // Конвертируем секунды обратно в минуты и секунды
        let totalSeconds = record.time ?? 0
        minutes = totalSeconds / 60
        seconds = totalSeconds % 60
        
        comment = record.comment ?? ""
        date = record.date
    }
    
    func saveRecord() {
        coreDataService.saveRecord(
            filmName: filmName.trimmingCharacters(in: .whitespacesAndNewlines),
            developerName: developerName.trimmingCharacters(in: .whitespacesAndNewlines),
            dilution: dilution.trimmingCharacters(in: .whitespacesAndNewlines),
            iso: Int(iso),
            temperature: temperature,
            time: totalSeconds,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : name.trimmingCharacters(in: .whitespacesAndNewlines),
            comment: comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : comment.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date
        )
    }
}

// MARK: - Preview

#Preview {
    CreateRecordView()
} 
