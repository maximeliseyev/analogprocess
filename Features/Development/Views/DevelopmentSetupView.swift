//
//  DevelopmentSetupView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CalculatedTimeSection: View {
    let time: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Calculated Time")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: onTap) {
                HStack {
                    Text("\(time / 60):\(String(format: "%02d", time % 60))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(Color.green.opacity(0.3))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
}

struct DevelopmentSetupView: View {
    @StateObject private var viewModel = DevelopmentSetupViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Темный фон
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Заголовок
                    DevelopmentHeaderView()
                    
                    // Параметры
                    DevelopmentParametersView(viewModel: viewModel)
                    
                    // Результат расчета
                    if let calculatedTime = viewModel.calculatedTime {
                        CalculatedTimeSection(
                            time: calculatedTime,
                            onTap: {
                                viewModel.showCalculator = true
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
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
                    onDismiss: { viewModel.showDilutionPicker = false }
                )
            }
            .sheet(isPresented: $viewModel.showISOPicker) {
                ISOPickerView(
                    iso: $viewModel.iso,
                    onDismiss: { viewModel.showISOPicker = false }
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


