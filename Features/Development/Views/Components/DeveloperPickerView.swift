    //
//  DeveloperPickerView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct DeveloperPickerView: View {
    let developers: [Developer]
    @Binding var selectedDeveloper: Developer?
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List(developers) { developer in
                Button(action: {
                    selectedDeveloper = developer
                    // Устанавливаем defaultDilution проявителя
                    selectedDilution = developer.defaultDilution ?? ""
                    onDismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(developer.name ?? "")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(developer.manufacturer ?? "") • \(developer.defaultDilution ?? "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedDeveloper?.id == developer.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите проявитель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct DeveloperPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperPickerView(
            developers: [],
            selectedDeveloper: .constant(nil),
            selectedDilution: .constant(""),
            onDismiss: {}
        )
    }
} 
