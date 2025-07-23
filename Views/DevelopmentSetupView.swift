//
//  DevelopmentSetupView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct DevelopmentSetupView: View {
    @StateObject private var dataService = CoreDataService.shared
    @State private var selectedFilm: Film?
    @State private var selectedDeveloper: Developer?
    @State private var selectedDilution: String = ""
    @State private var temperature: Double = 20.0
    @State private var iso: Int = 400
    @State private var calculatedTime: Int?
    @State private var showCalculator = false
    
    // Для выпадающих списков
    @State private var showFilmPicker = false
    @State private var showDeveloperPicker = false
    @State private var showDilutionPicker = false
    @State private var showISOPicker = false
    @State private var showTemperaturePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Темный фон
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Заголовок
                    VStack(spacing: 10) {
                        Text("Настройка проявки")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Выберите параметры для расчета времени проявки")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Параметры в стиле изображения
                    VStack(spacing: 20) {
                        ParameterRow(
                            label: "Film:",
                            value: selectedFilm?.name ?? "Выберите пленку",
                            onTap: { showFilmPicker = true }
                        )
                        
                        ParameterRow(
                            label: "Developer:",
                            value: selectedDeveloper?.name ?? "Выберите проявитель",
                            onTap: { showDeveloperPicker = true }
                        )
                        
                        ParameterRow(
                            label: "Dilution:",
                            value: selectedDilution.isEmpty ? "Выберите разбавление" : selectedDilution,
                            onTap: { showDilutionPicker = true }
                        )
                        
                        ParameterRow(
                            label: "ISO/EI:",
                            value: "\(iso)",
                            onTap: { showISOPicker = true }
                        )
                        
                        ParameterRow(
                            label: "Temperature (°C):",
                            value: "\(Int(temperature))°C (Standard)",
                            onTap: { showTemperaturePicker = true }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Результат расчета
                    if let calculatedTime = calculatedTime {
                        CalculatedTimeSection(
                            time: calculatedTime,
                            onTap: {
                                showCalculator = true
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCalculator) {
                if let calculatedTime = calculatedTime {
                    ContentView(initialTime: calculatedTime)
                }
            }
            .sheet(isPresented: $showFilmPicker) {
                FilmPickerView(
                    films: dataService.films,
                    selectedFilm: $selectedFilm,
                    iso: $iso,
                    onDismiss: { showFilmPicker = false }
                )
            }
            .sheet(isPresented: $showDeveloperPicker) {
                DeveloperPickerView(
                    developers: dataService.developers,
                    selectedDeveloper: $selectedDeveloper,
                    selectedDilution: $selectedDilution,
                    onDismiss: { showDeveloperPicker = false }
                )
            }
            .sheet(isPresented: $showDilutionPicker) {
                DilutionPickerView(
                    dilutions: getAvailableDilutions(),
                    selectedDilution: $selectedDilution,
                    onDismiss: { showDilutionPicker = false }
                )
            }
            .sheet(isPresented: $showISOPicker) {
                ISOPickerView(
                    iso: $iso,
                    onDismiss: { showISOPicker = false }
                )
            }
            .sheet(isPresented: $showTemperaturePicker) {
                TemperaturePickerView(
                    temperature: $temperature,
                    onDismiss: { showTemperaturePicker = false }
                )
            }
            .onChange(of: selectedFilm) { _ in
                calculateTimeAutomatically()
            }
            .onChange(of: selectedDeveloper) { _ in
                // При смене проявителя устанавливаем его defaultDilution
                if let developer = selectedDeveloper {
                    selectedDilution = developer.defaultDilution ?? ""
                }
                calculateTimeAutomatically()
            }
            .onChange(of: selectedDilution) { _ in
                calculateTimeAutomatically()
            }
            .onChange(of: iso) { _ in
                calculateTimeAutomatically()
            }
            .onChange(of: temperature) { _ in
                calculateTimeAutomatically()
            }
        }
    }
    
    private func calculateTimeAutomatically() {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              !selectedDilution.isEmpty else {
            calculatedTime = nil
            return
        }
        
        let parameters = DevelopmentParameters(
            film: film,
            developer: developer,
            dilution: selectedDilution,
            temperature: temperature,
            iso: iso
        )
        
        calculatedTime = dataService.calculateDevelopmentTime(parameters: parameters)
    }
    
    private func getAvailableDilutions() -> [String] {
        guard let film = selectedFilm,
              let developer = selectedDeveloper,
              let filmId = film.id,
              let developerId = developer.id else {
            return []
        }
        
        // Получаем доступные разбавления из Core Data
        let availableDilutions = dataService.getAvailableDilutions(for: filmId, developerId: developerId)
        
        // Если разбавлений нет, возвращаем defaultDilution проявителя
        if availableDilutions.isEmpty {
            return [developer.defaultDilution ?? ""]
        }
        
        return availableDilutions
    }
}

// Вспомогательные структуры для совместимости
struct FilmData {
    let id: String
    let name: String
    let manufacturer: String
    let type: String
    let description: String
    let defaultISO: Int
}

struct DeveloperData {
    let id: String
    let name: String
    let manufacturer: String
    let type: String
    let description: String
    let defaultDilution: String
}

struct ParameterRow: View {
    let label: String
    let value: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: onTap) {
                HStack {
                    Text(value)
                        .font(.body)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct FilmPickerView: View {
    let films: [Film]
    @Binding var selectedFilm: Film?
    @Binding var iso: Int
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List(films) { film in
                Button(action: {
                    selectedFilm = film
                    iso = Int(film.defaultISO)
                    onDismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(film.name ?? "")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(film.manufacturer) • ISO \(film.defaultISO)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedFilm?.id == film.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите пленку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct DeveloperPickerView: View {
    let developers: [Developer]
    @Binding var selectedDeveloper: Developer?
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List(developers) { developer in
                Button(action: {
                    selectedDeveloper = developer
                    // Устанавливаем defaultDilution проявителя
                    selectedDilution = developer.defaultDilution ?? ""
                    onDismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(developer.name ?? "")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("\(developer.manufacturer) • \(developer.defaultDilution ?? "")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedDeveloper?.id == developer.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите проявитель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct DilutionPickerView: View {
    let dilutions: [String]
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if dilutions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Нет доступных разбавлений")
                            .font(.headline)
                        
                        Text("Для выбранной комбинации пленки и проявителя нет данных о разбавлениях")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(dilutions, id: \.self) { dilution in
                        Button(action: {
                            selectedDilution = dilution
                            onDismiss()
                        }) {
                            HStack {
                                Text(dilution)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedDilution == dilution {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Выберите разбавление")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct ISOPickerView: View {
    @Binding var iso: Int
    let onDismiss: () -> Void
    
    private let availableISOs = [50, 100, 125, 200, 250, 400, 500, 800, 1600, 3200, 6400]
    
    var body: some View {
        NavigationView {
            List(availableISOs, id: \.self) { isoValue in
                Button(action: {
                    iso = isoValue
                    onDismiss()
                }) {
                    HStack {
                        Text("ISO \(isoValue)")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if iso == isoValue {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите ISO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct TemperaturePickerView: View {
    @Binding var temperature: Double
    let onDismiss: () -> Void
    
    private let temperatures = Array(stride(from: 14.0, through: 25.0, by: 0.5))
    
    var body: some View {
        NavigationView {
            List(temperatures, id: \.self) { temp in
                Button(action: {
                    temperature = temp
                    onDismiss()
                }) {
                    HStack {
                        Text("\(temp, specifier: "%.1f")°C")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if temperature == temp {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите температуру")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct CalculatedTimeSection: View {
    let time: Int
    let onTap: () -> Void
    
    private var minutes: Int {
        time / 60
    }
    
    private var seconds: Int {
        time % 60
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Время проявки")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: onTap) {
                VStack(spacing: 8) {
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    Text("Нажмите для перехода к калькулятору")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct DevelopmentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        DevelopmentSetupView()
    }
} 