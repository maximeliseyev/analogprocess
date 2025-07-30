    //
//  DeveloperPickerView.swift
//  Film Lab
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
    let onDeveloperSelected: ((Developer) -> Void)?
    
    @State private var searchText = ""
    
    var filteredDevelopers: [Developer] {
        if searchText.isEmpty {
            return developers
        } else {
            return developers.filter { developer in
                let developerName = developer.name ?? ""
                let manufacturer = developer.manufacturer ?? ""
                let searchQuery = searchText.lowercased()
                
                return developerName.lowercased().contains(searchQuery) ||
                       manufacturer.lowercased().contains(searchQuery)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredDevelopers) { developer in
                        Button(action: {
                            selectedDeveloper = developer
                            selectedDilution = developer.defaultDilution ?? ""
                            onDeveloperSelected?(developer)
                            onDismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(developer.name ?? "")
                                        .pickerTitleStyle()
                                    
                                    Text("\(developer.manufacturer ?? "") • \(developer.defaultDilution ?? "")")
                                        .pickerSubtitleStyle()
                                }
                                
                                Spacer()
                                
                                if selectedDeveloper?.id == developer.id {
                                    Image(systemName: "checkmark")
                                        .checkmarkStyle()
                                }
                            }
                            .pickerCardStyle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search developers...")
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

struct DeveloperPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperPickerView(
            developers: [],
            selectedDeveloper: .constant(nil),
            selectedDilution: .constant(""),
            onDismiss: {},
            onDeveloperSelected: { _ in }
        )
    }
}
