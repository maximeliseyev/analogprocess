//
//  SwiftDataTestView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI

struct SwiftDataTestView: View {
    @StateObject private var swiftDataService = SwiftDataService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Films") {
                    ForEach(swiftDataService.getFilms(), id: \.id) { film in
                        VStack(alignment: .leading) {
                            Text(film.name)
                                .font(.headline)
                            Text("\(film.manufacturer) - ISO \(film.defaultISO)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Developers") {
                    ForEach(swiftDataService.getDevelopers(), id: \.id) { developer in
                        VStack(alignment: .leading) {
                            Text(developer.name)
                                .font(.headline)
                            Text("\(developer.manufacturer) - \(developer.type)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Fixers") {
                    ForEach(swiftDataService.getFixers(), id: \.id) { fixer in
                        VStack(alignment: .leading) {
                            Text(fixer.name)
                                .font(.headline)
                            Text("\(fixer.type) - \(fixer.time / 60) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let warning = fixer.warning {
                                Text(warning)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                
                Section("Temperature Multipliers") {
                    ForEach(swiftDataService.getTemperatureMultipliers(), id: \.temperature) { multiplier in
                        HStack {
                            Text("\(multiplier.temperature)°C")
                            Spacer()
                            Text("× \(multiplier.multiplier, specifier: "%.1f")")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("SwiftData Test")
            .refreshable {
                swiftDataService.refreshData()
            }
        }
    }
}

#Preview {
    SwiftDataTestView()
}
