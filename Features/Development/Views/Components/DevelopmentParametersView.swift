//
//  DevelopmentParametersView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ParameterRow: View {
    let label: LocalizedStringKey
    let value: String
    let onTap: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: onTap) {
                HStack {
                    Text(value)
                        .font(.body)
                        .foregroundColor(isDisabled ? .gray : .white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(isDisabled ? .gray.opacity(0.5) : .gray)
                        .font(.caption)
                }
                .padding()
                .background(isDisabled ? Color.gray.opacity(0.1) : Color.gray.opacity(0.3))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDisabled)
        }
    }
}

struct DevelopmentParametersView: View {
    @ObservedObject var viewModel: DevelopmentSetupViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            ParameterRow(
                label: LocalizedStringKey("film"),
                value: viewModel.selectedFilm?.name ?? "Select Film",
                onTap: { viewModel.showFilmPicker = true },
                isDisabled: false
            )
            
            ParameterRow(
                label: LocalizedStringKey("developer"),
                value: viewModel.selectedDeveloper?.name ?? "Select Developer",
                onTap: { viewModel.showDeveloperPicker = true },
                isDisabled: false
            )
            
            ParameterRow(
                label: LocalizedStringKey("dilution"),
                value: viewModel.selectedDilution.isEmpty ? "Select Dilution" : viewModel.selectedDilution,
                onTap: { viewModel.showDilutionPicker = true },
                isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil
            )
            
            ParameterRow(
                label: LocalizedStringKey("iso"),
                value: "\(viewModel.iso)",
                onTap: { viewModel.showISOPicker = true },
                isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil || viewModel.selectedDilution.isEmpty
            )
            
            ParameterRow(
                label: LocalizedStringKey("temperature"),
                value: "\(Int(viewModel.temperature))°C (Standard)",
                onTap: { viewModel.showTemperaturePicker = true },
                isDisabled: false
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
