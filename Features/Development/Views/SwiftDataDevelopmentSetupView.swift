//
//  SwiftDataDevelopmentSetupView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import CoreData
import SwiftData

struct SwiftDataDevelopmentSetupView: View {
    @StateObject private var viewModel = SwiftDataDevelopmentSetupViewModel()

    var body: some View {
        KeyboardAwareView {
            ZStack(alignment: .topLeading) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Data Mode Toggle
                    HStack {
                        Text("Data Mode:")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            viewModel.useSwiftData.toggle()
                        }) {
                            Text(viewModel.useSwiftData ? "SwiftData" : "Core Data")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    DevelopmentParametersView(viewModel: viewModel)
                    
                    if let calculatedTime = viewModel.calculatedTime {
                        CalculatedTimeSection(
                            time: calculatedTime,
                            temperature: viewModel.temperature,
                            filmName: viewModel.selectedFilmName,
                            developerName: viewModel.selectedDeveloperName,
                            onCalculatorTap: {
                                viewModel.navigateToCalculator = true
                            },
                            onTimerTap: {
                                viewModel.navigateToTimer = true
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $viewModel.showFilmPicker) {
            if viewModel.useSwiftData {
                SwiftDataFilmPickerView(
                    films: viewModel.films,
                    selectedFilm: $viewModel.selectedFilm,
                    swiftDataFilms: viewModel.swiftDataFilms,
                    selectedSwiftDataFilm: $viewModel.selectedSwiftDataFilm,
                    iso: $viewModel.iso,
                    onDismiss: { viewModel.showFilmPicker = false },
                    onFilmSelected: { film in
                        viewModel.selectFilm(film)
                    },
                    onSwiftDataFilmSelected: { swiftDataFilm in
                        viewModel.selectSwiftDataFilm(swiftDataFilm)
                    },
                    useSwiftData: $viewModel.useSwiftData
                )
            } else {
                FilmPickerView(
                    films: viewModel.films,
                    selectedFilm: $viewModel.selectedFilm,
                    iso: $viewModel.iso,
                    onDismiss: { viewModel.showFilmPicker = false },
                    onFilmSelected: { film in
                        viewModel.selectFilm(film)
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showDeveloperPicker) {
            if viewModel.useSwiftData {
                SwiftDataDeveloperPickerView(
                    developers: viewModel.developers,
                    selectedDeveloper: $viewModel.selectedDeveloper,
                    swiftDataDevelopers: viewModel.swiftDataDevelopers,
                    selectedSwiftDataDeveloper: $viewModel.selectedSwiftDataDeveloper,
                    selectedDilution: $viewModel.selectedDilution,
                    onDismiss: { viewModel.showDeveloperPicker = false },
                    onDeveloperSelected: { developer in
                        viewModel.selectDeveloper(developer)
                    },
                    onSwiftDataDeveloperSelected: { swiftDataDeveloper in
                        viewModel.selectSwiftDataDeveloper(swiftDataDeveloper)
                    },
                    useSwiftData: $viewModel.useSwiftData
                )
            } else {
                DeveloperPickerView(
                    developers: viewModel.developers,
                    selectedDeveloper: $viewModel.selectedDeveloper,
                    selectedDilution: $viewModel.selectedDilution,
                    onDismiss: { viewModel.showDeveloperPicker = false },
                    onDeveloperSelected: { developer in
                        viewModel.selectDeveloper(developer)
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showDilutionPicker) {
            DilutionPickerView(
                dilutions: viewModel.getAvailableDilutions(),
                selectedDilution: $viewModel.selectedDilution,
                onDismiss: { viewModel.showDilutionPicker = false },
                isDisabled: viewModel.selectedFilm == nil && viewModel.selectedSwiftDataFilm == nil || 
                           viewModel.selectedDeveloper == nil && viewModel.selectedSwiftDataDeveloper == nil,
                onDilutionSelected: { dilution in
                    viewModel.selectDilution(dilution)
                }
            )
        }
        .sheet(isPresented: $viewModel.showISOPicker) {
            ISOPickerView(
                iso: $viewModel.iso,
                onDismiss: { viewModel.showISOPicker = false },
                availableISOs: viewModel.getAvailableISOs()
            )
        }
        .sheet(isPresented: $viewModel.showTemperaturePicker) {
            TemperaturePickerView(
                temperature: $viewModel.temperature,
                onDismiss: { viewModel.showTemperaturePicker = false }
            )
        }
        .sheet(isPresented: $viewModel.showFixerPicker) {
            if viewModel.useSwiftData {
                SwiftDataFixerPickerView(
                    fixers: viewModel.fixers,
                    selectedFixer: $viewModel.selectedFixer,
                    swiftDataFixers: viewModel.swiftDataFixers,
                    selectedSwiftDataFixer: $viewModel.selectedSwiftDataFixer,
                    onDismiss: { viewModel.showFixerPicker = false },
                    onFixerSelected: { fixer in
                        viewModel.selectFixer(fixer)
                    },
                    onSwiftDataFixerSelected: { swiftDataFixer in
                        viewModel.selectSwiftDataFixer(swiftDataFixer)
                    },
                    useSwiftData: $viewModel.useSwiftData
                )
            } else {
                FixerPickerView(
                    fixers: viewModel.fixers,
                    selectedFixer: $viewModel.selectedFixer,
                    onDismiss: { viewModel.showFixerPicker = false },
                    onFixerSelected: { fixer in
                        viewModel.selectFixer(fixer)
                    }
                )
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToCalculator) {
            if let calculatedTime = viewModel.calculatedTime {
                CalculatorView(initialTime: calculatedTime, initialTemperature: viewModel.temperature)
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToTimer) {
            if let calculatedTime = viewModel.calculatedTime {
                let minutes = calculatedTime / 60
                let seconds = calculatedTime % 60
                let timerLabel = "\(viewModel.selectedFilmName) / \(viewModel.selectedDeveloperName)"
                
                TimerView(
                    timerLabel: timerLabel,
                    totalMinutes: minutes,
                    totalSeconds: seconds
                )
            }
        }
        .onChange(of: viewModel.iso) { oldValue, newValue in
            viewModel.updateISO(Int(newValue))
        }
        .onChange(of: viewModel.temperature) { oldValue, newValue in
            viewModel.updateTemperature(newValue)
        }
        .navigationTitle(LocalizedStringKey("presets"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
struct SwiftDataDevelopmentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftDataDevelopmentSetupView()
            .previewDisplayName("SwiftData Development setup")
    }
}
