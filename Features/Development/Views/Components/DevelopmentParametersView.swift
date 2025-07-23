//
//  DevelopmentParametersView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

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

struct DevelopmentParametersView: View {
    @ObservedObject var viewModel: DevelopmentSetupViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ParameterRow(
                label: "Film:",
                value: viewModel.selectedFilm?.name ?? "Выберите пленку",
                onTap: { viewModel.showFilmPicker = true }
            )
            
            ParameterRow(
                label: "Developer:",
                value: viewModel.selectedDeveloper?.name ?? "Выберите проявитель",
                onTap: { viewModel.showDeveloperPicker = true }
            )
            
            ParameterRow(
                label: "Dilution:",
                value: viewModel.selectedDilution.isEmpty ? "Выберите разбавление" : viewModel.selectedDilution,
                onTap: { viewModel.showDilutionPicker = true }
            )
            
            ParameterRow(
                label: "ISO/EI:",
                value: "\(viewModel.iso)",
                onTap: { viewModel.showISOPicker = true }
            )
            
            ParameterRow(
                label: "Temperature (°C):",
                value: "\(Int(viewModel.temperature))°C (Standard)",
                onTap: { viewModel.showTemperaturePicker = true }
            )
        }
        .padding(.horizontal, 20)
    }
}

struct DevelopmentParametersView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DevelopmentParametersView(viewModel: DevelopmentSetupViewModel())
        }
    }
} 