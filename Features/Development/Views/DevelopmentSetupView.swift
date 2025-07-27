import SwiftUI
import CoreData

struct DevelopmentSetupView: View {
    @StateObject private var viewModel = DevelopmentSetupViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {                    
                    DevelopmentParametersView(viewModel: viewModel)
                    
                    if let calculatedTime = viewModel.calculatedTime {
                        CalculatedTimeSection(
                            time: calculatedTime,
                            onTap: {
                                viewModel.showCalculator = true
                            }
                        )
                    }
                    
                    // Debug button to reload data
                    #if DEBUG
                    Button("Force Reload Data") {
                        viewModel.reloadData()
                    }
                    .foregroundColor(.blue)
                    .padding()
                    #endif
                    
                    Spacer()
                }
            }
            .navigationTitle(LocalizedStringKey("developmentSetup"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showCalculator) {
                if viewModel.calculatedTime != nil {
                    CalculatorView()
                }
            }
            .sheet(isPresented: $viewModel.showFilmPicker) {
                FilmPickerView(
                    films: viewModel.films,
                    selectedFilm: $viewModel.selectedFilm,
                    iso: $viewModel.iso,
                    onDismiss: { viewModel.showFilmPicker = false }
                )
            }
            .sheet(isPresented: $viewModel.showDeveloperPicker) {
                DeveloperPickerView(
                    developers: viewModel.developers,
                    selectedDeveloper: $viewModel.selectedDeveloper,
                    selectedDilution: $viewModel.selectedDilution,
                    onDismiss: { viewModel.showDeveloperPicker = false }
                )
            }
            .sheet(isPresented: $viewModel.showDilutionPicker) {
                DilutionPickerView(
                    dilutions: viewModel.getAvailableDilutions(),
                    selectedDilution: $viewModel.selectedDilution,
                    onDismiss: { viewModel.showDilutionPicker = false },
                    isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil
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
