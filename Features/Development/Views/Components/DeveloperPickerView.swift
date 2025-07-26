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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedStringKey("selectDeveloper"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }
}
