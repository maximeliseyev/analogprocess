import SwiftUI
import CoreData

struct DevelopmentSetupView: View {
    @StateObject private var viewModel = DevelopmentSetupViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {                    
                    DevelopmentParametersView(viewModel: viewModel)
                    
                    if let calculatedTime = viewModel.calculatedTime {
                        CalculatedTimeSection(
                            time: calculatedTime,
                            onCalculatorTap: {
                                viewModel.showCalculator = true
                            },
                            onTimerTap: {
                                viewModel.startTimer()
                            }
                        )
                    }
                    
//                    #if DEBUG
//                    Button("Force Reload Data") {
//                        viewModel.reloadData()
//                    }
//                    .foregroundColor(.blue)
//                    .padding()
//                    #endif
                    
                    Spacer()
                }
            }
            .navigationTitle(LocalizedStringKey("developmentSetup"))
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $viewModel.showTimer) {
                if let calculatedTime = viewModel.calculatedTime {
                    let minutes = calculatedTime / 60
                    let seconds = calculatedTime % 60
                    let timerLabel = "\(viewModel.selectedFilm?.name ?? "") + \(viewModel.selectedDeveloper?.name ?? "")"
                    
                    TimerView(
                        timerLabel: timerLabel,
                        totalMinutes: minutes,
                        totalSeconds: seconds
                    )
                }
            }
            .onChange(of: viewModel.iso) { _ in
                viewModel.updateISO(viewModel.iso)
            }
            .onChange(of: viewModel.temperature) { _ in
                viewModel.updateTemperature(viewModel.temperature)
            }
        }
    }
}

// MARK: - Preview
struct DevelopmentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        DevelopmentSetupView()
            .previewDisplayName("Development setup")
    }
}
