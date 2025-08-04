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
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(theme.primaryText)
            
            Button(action: onTap) {
                HStack {
                    Text(value)
                        .font(.body)
                        .foregroundColor(isDisabled ? theme.secondaryText : theme.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(isDisabled ? theme.secondaryText.opacity(0.5) : theme.secondaryText)
                        .font(.caption)
                }
                .padding()
                .background(isDisabled ? theme.secondaryBackground : theme.parameterCardBackground)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDisabled)
        }
    }
}

struct DevelopmentParametersView: View {
    @ObservedObject var viewModel: DevelopmentSetupViewModel
    @Environment(\.theme) private var theme
    
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
            ThemeManager.shared.primaryBackground.ignoresSafeArea()
            DevelopmentParametersView(viewModel: DevelopmentSetupViewModel())
        }
    }
} 
