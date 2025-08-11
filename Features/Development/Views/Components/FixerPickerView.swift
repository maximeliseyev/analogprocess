//
//  SwiftDataFixerPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct FixerPickerView: View {
    // MARK: - SwiftData Properties
    let swiftDataFixers: [SwiftDataFixer]
    @Binding var selectedSwiftDataFixer: SwiftDataFixer?
    
    // MARK: - Shared Properties
    let onDismiss: () -> Void
    let onSwiftDataFixerSelected: (SwiftDataFixer) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // SwiftData Fixers
                List {
                    ForEach(swiftDataFixers, id: \.id) { fixer in
                        Button(action: {
                            selectedSwiftDataFixer = fixer
                            onSwiftDataFixerSelected(fixer)
                            onDismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(fixer.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(getFixerTypeDisplayName(fixer.type))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text("\(fixer.time / 60) мин")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(4)
                                        
                                        if let warning = fixer.warning {
                                            Text(warning)
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.orange.opacity(0.1))
                                                .cornerRadius(4)
                                        }
                                    }
                                }
                                
                                Spacer()
                                
                                if selectedSwiftDataFixer?.id == fixer.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("fixerSelection"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    private func getFixerTypeDisplayName(_ type: String) -> String {
        switch type {
        case "rapid":
            return "Быстрый фиксаж"
        case "acid":
            return "Кислый фиксаж"
        case "neutral":
            return "Нейтральный фиксаж"
        default:
            return type
        }
    }
}

// MARK: - Preview
struct FixerPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FixerPickerView(
            swiftDataFixers: [],
            selectedSwiftDataFixer: .constant(nil as SwiftDataFixer?),
            onDismiss: {},
            onSwiftDataFixerSelected: { _ in }
        )
    }
}
