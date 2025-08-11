//
//  SwiftDataDeveloperPickerView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import CoreData
import SwiftData

struct SwiftDataDeveloperPickerView: View {
    // MARK: - Core Data Properties
    let developers: [Developer]
    @Binding var selectedDeveloper: Developer?
    
    // MARK: - SwiftData Properties
    let swiftDataDevelopers: [SwiftDataDeveloper]
    @Binding var selectedSwiftDataDeveloper: SwiftDataDeveloper?
    
    // MARK: - Shared Properties
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    let onDeveloperSelected: ((Developer) -> Void)?
    let onSwiftDataDeveloperSelected: ((SwiftDataDeveloper) -> Void)?
    
    // MARK: - Data Mode
    @Binding var useSwiftData: Bool
    
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    
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
    
    var filteredSwiftDataDevelopers: [SwiftDataDeveloper] {
        if searchText.isEmpty {
            return swiftDataDevelopers
        } else {
            return swiftDataDevelopers.filter { developer in
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
                    // Data Mode Toggle
                    HStack {
                        Text("Data Mode:")
                            .font(.headline)
                        Spacer()
                        Button(useSwiftData ? "SwiftData" : "Core Data") {
                            useSwiftData.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if useSwiftData {
                                // SwiftData Developers
                                ForEach(filteredSwiftDataDevelopers) { developer in
                                    Button(action: {
                                        selectedSwiftDataDeveloper = developer
                                        selectedDilution = developer.defaultDilution ?? ""
                                        onSwiftDataDeveloperSelected?(developer)
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
                                            
                                            if selectedSwiftDataDeveloper?.id == developer.id {
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
                            } else {
                                // Core Data Developers
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

struct SwiftDataDeveloperPickerView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftDataDeveloperPickerView(
            developers: [],
            selectedDeveloper: .constant(nil),
            swiftDataDevelopers: [],
            selectedSwiftDataDeveloper: .constant(nil),
            selectedDilution: .constant(""),
            onDismiss: {},
            onDeveloperSelected: { _ in },
            onSwiftDataDeveloperSelected: { _ in },
            useSwiftData: .constant(false)
        )
    }
}
