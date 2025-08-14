//
//  SwiftDataDevelopmentSetupView.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData

struct DevelopmentSetupView: View {
    @StateObject private var viewModel = DevelopmentSetupViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Mode Selection Picker
                    Picker("Process Mode", selection: $viewModel.selectedMode) {
                        ForEach(ProcessMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 20)
                    .onChange(of: viewModel.selectedMode) { _, newMode in
                        viewModel.updateMode(newMode)
                    }
                    
                    DevelopmentParametersView(viewModel: viewModel)
                    
                    if let calculatedTime = viewModel.calculatedTime {
                        CalculatedTimeSection(
                            time: calculatedTime,
                            temperature: viewModel.temperature,
                            filmName: viewModel.selectedFilmName,
                            developerName: viewModel.selectedMode == .developing ? viewModel.selectedDeveloperName : "Fixer",
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
        .sheet(isPresented: $viewModel.showDeveloperPicker) {
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
        .sheet(isPresented: $viewModel.showDilutionPicker) {
            DilutionPickerView(
                dilutions: viewModel.getAvailableDilutions(),
                selectedDilution: $viewModel.selectedDilution,
                onDismiss: { viewModel.showDilutionPicker = false },
                isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil,
                onDilutionSelected: { dilution in
                    viewModel.selectDilution(dilution)
                }
            )
        }
        .sheet(isPresented: $viewModel.showFixerPicker) {
            FixerPickerView(
                swiftDataFixers: viewModel.fixers,
                selectedSwiftDataFixer: $viewModel.selectedFixer,
                onDismiss: { viewModel.showFixerPicker = false },
                onSwiftDataFixerSelected: { fixer in
                    viewModel.selectFixer(fixer)
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
        .onAppear {
            viewModel.reloadData()
        }
    }
}

struct DevelopmentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        DevelopmentSetupView()
    }
}
