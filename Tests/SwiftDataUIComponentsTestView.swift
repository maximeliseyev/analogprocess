//
//  SwiftDataUIComponentsTestView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import CoreData
import SwiftData

struct SwiftDataUIComponentsTestView: View {
    @StateObject private var coreDataService = CoreDataService.shared
    @StateObject private var swiftDataService = SwiftDataService.shared
    
    // MARK: - Core Data State
    @State private var selectedFilm: Film?
    @State private var selectedDeveloper: Developer?
    @State private var selectedFixer: Fixer?
    @State private var selectedDilution = ""
    @State private var iso: Int32 = 400
    
    // MARK: - SwiftData State
    @State private var selectedSwiftDataFilm: SwiftDataFilm?
    @State private var selectedSwiftDataDeveloper: SwiftDataDeveloper?
    @State private var selectedSwiftDataFixer: SwiftDataFixer?
    
    // MARK: - UI State
    @State private var useSwiftData = false
    @State private var showFilmPicker = false
    @State private var showDeveloperPicker = false
    @State private var showFixerPicker = false
    
    // MARK: - Computed Properties
    
    private var dataModeToggle: some View {
        HStack {
            Text("Data Mode:")
                .font(.headline)
            Spacer()
            Button(action: {
                useSwiftData.toggle()
            }) {
                Text(useSwiftData ? "SwiftData" : "Core Data")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var selectedDataDisplay: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Data:")
                .font(.headline)
            
            if useSwiftData {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Film: \(selectedSwiftDataFilm?.name ?? "None")")
                    Text("Developer: \(selectedSwiftDataDeveloper?.name ?? "None")")
                    Text("Dilution: \(selectedDilution)")
                    Text("ISO: \(iso)")
                    Text("Fixer: \(selectedSwiftDataFixer?.name ?? "None")")
                }
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Film: \(selectedFilm?.name ?? "None")")
                    Text("Developer: \(selectedDeveloper?.name ?? "None")")
                    Text("Dilution: \(selectedDilution)")
                    Text("ISO: \(iso)")
                    Text("Fixer: \(selectedFixer?.name ?? "None")")
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var pickerButtons: some View {
        VStack(spacing: 15) {
            Button("Select Film") {
                showFilmPicker = true
            }
            .buttonStyle(.bordered)
            
            Button("Select Developer") {
                showDeveloperPicker = true
            }
            .buttonStyle(.bordered)
            
            Button("Select Fixer") {
                showFixerPicker = true
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var availableDataCount: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Available Data:")
                .font(.headline)
            
                                    if useSwiftData {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Films: \(swiftDataService.films.count)")
                                Text("Developers: \(swiftDataService.developers.count)")
                                Text("Fixers: \(swiftDataService.fixers.count)")
                            }
                        } else {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Films: \(coreDataService.films.count)")
                    Text("Developers: \(coreDataService.developers.count)")
                    Text("Fixers: \(coreDataService.fixers.count)")
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var reloadButton: some View {
        Button("Reload Data") {
            if useSwiftData {
                swiftDataService.refreshData()
            } else {
                coreDataService.refreshData()
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    dataModeToggle
                    selectedDataDisplay
                    pickerButtons
                    availableDataCount
                    reloadButton
                }
                .padding()
            }
            .navigationTitle("SwiftData UI Components Test")
            .sheet(isPresented: $showFilmPicker) {
                SwiftDataFilmPickerView(
                    films: coreDataService.films,
                    selectedFilm: $selectedFilm,
                    swiftDataFilms: swiftDataService.films,
                    selectedSwiftDataFilm: $selectedSwiftDataFilm,
                    iso: $iso,
                    onDismiss: { showFilmPicker = false },
                    onFilmSelected: { film in
                        selectedFilm = film
                        iso = Int32(film.defaultISO)
                    },
                    onSwiftDataFilmSelected: { film in
                        selectedSwiftDataFilm = film
                        iso = Int32(film.defaultISO)
                    },
                    useSwiftData: $useSwiftData
                )
            }
            .sheet(isPresented: $showDeveloperPicker) {
                SwiftDataDeveloperPickerView(
                    developers: coreDataService.developers,
                    selectedDeveloper: $selectedDeveloper,
                    swiftDataDevelopers: swiftDataService.developers,
                    selectedSwiftDataDeveloper: $selectedSwiftDataDeveloper,
                    selectedDilution: $selectedDilution,
                    onDismiss: { showDeveloperPicker = false },
                    onDeveloperSelected: { developer in
                        selectedDeveloper = developer
                        selectedDilution = developer.defaultDilution ?? ""
                    },
                    onSwiftDataDeveloperSelected: { developer in
                        selectedSwiftDataDeveloper = developer
                        selectedDilution = developer.defaultDilution ?? ""
                    },
                    useSwiftData: $useSwiftData
                )
            }
            .sheet(isPresented: $showFixerPicker) {
                SwiftDataFixerPickerView(
                    fixers: coreDataService.fixers,
                    selectedFixer: $selectedFixer,
                    swiftDataFixers: swiftDataService.fixers,
                    selectedSwiftDataFixer: $selectedSwiftDataFixer,
                    onDismiss: { showFixerPicker = false },
                    onFixerSelected: { fixer in
                        selectedFixer = fixer
                    },
                    onSwiftDataFixerSelected: { fixer in
                        selectedSwiftDataFixer = fixer
                    },
                    useSwiftData: $useSwiftData
                )
            }
        }
        .onAppear {
            // Load initial data
            coreDataService.refreshData()
            swiftDataService.refreshData()
        }
    }
}

struct SwiftDataUIComponentsTestView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftDataUIComponentsTestView()
            .modelContainer(for: [SwiftDataFilm.self, SwiftDataDeveloper.self, SwiftDataFixer.self], inMemory: true)
    }
}
