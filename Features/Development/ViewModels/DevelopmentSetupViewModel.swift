import SwiftUI
import Combine

@MainActor
class DevelopmentSetupViewModel<DataServiceType: DataService>: ObservableObject where DataServiceType.Film: Identifiable, DataServiceType.Developer: Identifiable, DataServiceType.Fixer: Identifiable {
    
    // MARK: - Properties
    @Published var selectedFilm: DataServiceType.Film?
    @Published var selectedDeveloper: DataServiceType.Developer?
    @Published var selectedFixer: DataServiceType.Fixer?
    @Published var selectedDilution: String = ""
    @Published var temperature: Int = 20
    @Published var iso: Int = Constants.ISO.defaultISO
    @Published var calculatedTime: Int?
    
    // MARK: - Mode Selection
    @Published var selectedMode: ProcessMode = .developing
    
    // MARK: - UI States
    @Published var showFilmPicker = false
    @Published var showDeveloperPicker = false
    @Published var showDilutionPicker = false
    @Published var showFixerPicker = false
    @Published var showISOPicker = false
    @Published var showTemperaturePicker = false
    
    // MARK: - Navigation
    @Published var navigateToCalculator = false
    @Published var navigateToTimer = false
    
    // MARK: - Services
    let dataService: DataServiceType
    
    init(dataService: DataServiceType) {
        self.dataService = dataService
    }
    
    // MARK: - Computed Properties
    var films: [DataServiceType.Film] {
        dataService.films
    }
    
    var developers: [DataServiceType.Developer] {
        dataService.developers
    }
    
    var fixers: [DataServiceType.Fixer] {
        dataService.fixers
    }
    
    var selectedFilmName: String {
        selectedFilm?.name ?? ""
    }
    
    var selectedDeveloperName: String {
        selectedDeveloper?.name ?? ""
    }
    
    var dilutionOptions: [String] {
        guard let film = selectedFilm, let developer = selectedDeveloper else { return [] }
        return dataService.getAvailableDilutions(filmId: film.id, developerId: developer.id)
    }
    
    var isoOptions: [Int] {
        guard let film = selectedFilm, let developer = selectedDeveloper, !selectedDilution.isEmpty else { return [] }
        return dataService.getAvailableISOs(filmId: film.id, developerId: developer.id, dilution: selectedDilution)
    }
    
    var isDilutionSelectionLocked: Bool {
        dilutionOptions.count <= 1
    }
    
    var isISOSelectionLocked: Bool {
        isoOptions.count <= 1
    }
    
    var isTemperatureSelectionLocked: Bool {
        false  // Temperature selection is always available
    }
    
    // MARK: - Public Methods
    func selectFilm(_ film: DataServiceType.Film) {
        selectedFilm = film
        iso = Int(film.defaultISO)
        calculateTimeAutomatically()
    }
    
    func selectDeveloper(_ developer: DataServiceType.Developer) {
        selectedDeveloper = developer
        selectedDilution = developer.defaultDilution ?? ""
        calculateTimeAutomatically()
    }
    
    func selectDilution(_ dilution: String) {
        selectedDilution = dilution
        calculateTimeAutomatically()
    }
    
    func selectFixer(_ fixer: DataServiceType.Fixer) {
        selectedFixer = fixer
        calculateTimeAutomatically()
    }
    
    func updateISO(_ newISO: Int) {
        iso = newISO
        calculateTimeAutomatically()
    }
    
    func updateTemperature(_ newTemperature: Int) {
        temperature = newTemperature
        calculateTimeAutomatically()
    }
    
    func updateMode(_ newMode: ProcessMode) {
        selectedMode = newMode
        calculateTimeAutomatically()
    }
    
    func reloadData() {
        dataService.refreshData()
        objectWillChange.send()
    }
    
    // MARK: - Private Methods
    private func calculateTimeAutomatically() {
        switch selectedMode {
        case .developing:
            guard let film = selectedFilm, let developer = selectedDeveloper else {
                calculatedTime = nil
                return
            }
            
            let parameters = DevelopmentParameters(film: film, developer: developer, dilution: selectedDilution, temperature: temperature, iso: iso, time: 0)
            calculatedTime = dataService.calculateDevelopmentTime(parameters: parameters)
            
        case .fixer:
            guard let fixer = selectedFixer else {
                calculatedTime = nil
                return
            }
            calculatedTime = Int(fixer.time)
        }
    }
}