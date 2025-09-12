//
//  SwiftDataUIComponentsTestView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct SwiftDataUIComponentsTestView: View {
    // MARK: - Services
    @StateObject private var swiftDataService: SwiftDataService
    
    init() {
        let container = SwiftDataPersistence.preview.modelContainer
        let githubService = GitHubDataService()
        let service = SwiftDataService(githubDataService: githubService, modelContainer: container)
        self._swiftDataService = StateObject(wrappedValue: service)
    }
    
    // MARK: - SwiftData State
    @State private var selectedFilm: SwiftDataFilm?
    @State private var selectedDeveloper: SwiftDataDeveloper?
    @State private var selectedFixer: SwiftDataFixer?
    @State private var selectedDilution: String = ""
    @State private var iso: Int32 = 400
    
    // MARK: - UI State
    @State private var showFilmPicker = false
    @State private var showDeveloperPicker = false
    @State private var showFixerPicker = false
    
    // MARK: - Computed Properties
    
    private var selectedDataDisplay: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected Data:")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Film: \(selectedFilm?.name ?? "None")")
                Text("Developer: \(selectedDeveloper?.name ?? "None")")
                Text("Dilution: \(selectedDilution)")
                Text("ISO: \(iso)")
                Text("Fixer: \(selectedFixer?.name ?? "None")")
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
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Films: \(swiftDataService.films.count)")
                Text("Developers: \(swiftDataService.developers.count)")
                Text("Fixers: \(swiftDataService.fixers.count)")
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("SwiftData UI Components Test")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        selectedDataDisplay
                        
                        pickerButtons
                        
                        availableDataCount
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showFilmPicker) {
            FilmPickerView(
                films: swiftDataService.films,
                selectedFilm: $selectedFilm,
                iso: $iso,
                onDismiss: { showFilmPicker = false },
                onFilmSelected: { film in
                    selectedFilm = film
                    iso = film.defaultISO
                }
            )
        }
        .sheet(isPresented: $showDeveloperPicker) {
            DeveloperPickerView(
                developers: swiftDataService.developers,
                selectedDeveloper: $selectedDeveloper,
                selectedDilution: $selectedDilution,
                onDismiss: { showDeveloperPicker = false },
                onDeveloperSelected: { developer in
                    selectedDeveloper = developer
                    selectedDilution = developer.defaultDilution ?? ""
                }
            )
        }
        .sheet(isPresented: $showFixerPicker) {
            FixerPickerView(
                swiftDataFixers: swiftDataService.fixers,
                selectedSwiftDataFixer: $selectedFixer,
                onDismiss: { showFixerPicker = false },
                onSwiftDataFixerSelected: { fixer in
                    selectedFixer = fixer
                }
            )
        }
        .navigationTitle("SwiftData UI Test")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SwiftDataUIComponentsTestView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftDataUIComponentsTestView()
    }
}
