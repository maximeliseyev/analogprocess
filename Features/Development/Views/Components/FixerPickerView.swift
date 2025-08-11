//
//  FixerPickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct FixerPickerView: View {
    let fixers: [Fixer]
    @Binding var selectedFixer: Fixer?
    let onDismiss: () -> Void
    let onFixerSelected: (Fixer) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(fixers, id: \.id) { fixer in
                    Button(action: {
                        selectedFixer = fixer
                        onFixerSelected(fixer)
                        onDismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fixer.name ?? "")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(getFixerTypeDisplayName(fixer.type ?? ""))
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
                            
                            if selectedFixer?.id == fixer.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
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
            fixers: [],
            selectedFixer: .constant(nil),
            onDismiss: {},
            onFixerSelected: { _ in }
        )
    }
}
