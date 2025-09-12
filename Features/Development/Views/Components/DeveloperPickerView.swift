//
//  SwiftDataDeveloperPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct DeveloperPickerView: View {
    // MARK: - SwiftData Properties
    let developers: [SwiftDataDeveloper]
    @Binding var selectedDeveloper: SwiftDataDeveloper?
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    let onDeveloperSelected: ((SwiftDataDeveloper) -> Void)?
    
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
    var filteredDevelopers: [SwiftDataDeveloper] {
        if searchText.isEmpty {
            return developers
        } else {
            return developers.filter { developer in
                let developerName = developer.name
                let manufacturer = developer.manufacturer
                let searchQuery = searchText.lowercased()
                
                return developerName.lowercased().contains(searchQuery) ||
                       manufacturer.lowercased().contains(searchQuery)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
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
                                            Text(developer.name)
                                                .pickerTitleStyle()
                                            
                                            Text("\(developer.manufacturer) • \(developer.defaultDilution ?? "")")
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
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "searchDevelopers"))
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
