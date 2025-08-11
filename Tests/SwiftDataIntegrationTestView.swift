//
//  SwiftDataIntegrationTestView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct SwiftDataIntegrationTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var swiftDataFilms: [SwiftDataFilm]
    @Query private var swiftDataDevelopers: [SwiftDataDeveloper]
    @Query private var swiftDataFixers: [SwiftDataFixer]
    @Query private var swiftDataTemperatureMultipliers: [SwiftDataTemperatureMultiplier]
    
    @StateObject private var swiftDataService = SwiftDataService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("SwiftData Films (\(swiftDataFilms.count))") {
                    ForEach(swiftDataFilms) { film in
                        VStack(alignment: .leading) {
                            Text(film.name)
                                .font(.headline)
                            Text("\(film.manufacturer) - ISO \(film.defaultISO)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("SwiftData Developers (\(swiftDataDevelopers.count))") {
                    ForEach(swiftDataDevelopers) { developer in
                        VStack(alignment: .leading) {
                            Text(developer.name)
                                .font(.headline)
                            Text("\(developer.manufacturer) - \(developer.defaultDilution ?? "N/A")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("SwiftData Fixers (\(swiftDataFixers.count))") {
                    ForEach(swiftDataFixers) { fixer in
                        VStack(alignment: .leading) {
                            Text(fixer.name)
                                .font(.headline)
                            Text("\(fixer.type) - \(fixer.time / 60) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("SwiftData Temperature Multipliers (\(swiftDataTemperatureMultipliers.count))") {
                    ForEach(swiftDataTemperatureMultipliers) { multiplier in
                        VStack(alignment: .leading) {
                            Text("\(multiplier.temperature)°C")
                                .font(.headline)
                            Text("Multiplier: \(multiplier.multiplier, specifier: "%.2f")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("SwiftData Integration Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Load Data") {
                        Task {
                            await loadTestData()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        clearData()
                    }
                }
            }
        }
    }
    
    private func loadTestData() async {
        await MainActor.run {
            swiftDataService.loadInitialData()
        }
    }
    
    private func clearData() {
        swiftDataService.clearAllData()
    }
}

#Preview {
    SwiftDataIntegrationTestView()
        .modelContainer(for: [SwiftDataFilm.self, SwiftDataDeveloper.self, SwiftDataFixer.self, SwiftDataTemperatureMultiplier.self], inMemory: true)
}
