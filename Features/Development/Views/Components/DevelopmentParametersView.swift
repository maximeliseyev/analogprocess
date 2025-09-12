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
                .foregroundColor(.primary)
            
            Button(action: onTap) {
                HStack {
                    Text(value)
                        .font(.body)
                        .foregroundColor(isDisabled ? .secondary : .primary)
                    
                    Spacer()
                    
                    if !isDisabled {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .padding()
                .background(isDisabled ? Color(uiColor: .systemGray6) : Color(uiColor: .secondarySystemBackground))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
    }
}

struct DevelopmentParametersView: View {
    @ObservedObject var viewModel: DevelopmentSetupViewModel<SwiftDataService>
    
    var body: some View {
        VStack(spacing: 12) {
            if viewModel.selectedMode == .developing {
                // Development parameters
                ParameterRow(
                    label: LocalizedStringKey("film"),
                    value: viewModel.selectedFilm?.name ?? String(localized: "selectFilm"),
                    onTap: { viewModel.showFilmPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: LocalizedStringKey("developer"),
                    value: viewModel.selectedDeveloper?.name ?? String(localized: "selectDeveloper"),
                    onTap: { viewModel.showDeveloperPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: LocalizedStringKey("dilution"),
                    value: viewModel.selectedDilution.isEmpty ? String(localized: "selectDilution") : viewModel.selectedDilution,
                    onTap: { viewModel.showDilutionPicker = true },
                    isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil || viewModel.isDilutionSelectionLocked
                )
                
                ParameterRow(
                    label: LocalizedStringKey("iso"),
                    value: "\(viewModel.iso)",
                    onTap: {
                        if !viewModel.isISOSelectionLocked {
                            viewModel.showISOPicker = true
                        }
                    },
                    isDisabled: viewModel.selectedFilm == nil || viewModel.selectedDeveloper == nil || viewModel.selectedDilution.isEmpty || viewModel.isISOSelectionLocked
                )
                if viewModel.isISOSelectionLocked {
                    Text(LocalizedStringKey("noAlternativeOptions"))
                        .captionTextStyle()
                }
                
                ParameterRow(
                    label: LocalizedStringKey("temperature"),
                    value: "\(viewModel.temperature)\(LocalizedStringKey("StandardC"))",
                    onTap: { viewModel.showTemperaturePicker = true },
                    isDisabled: viewModel.isTemperatureSelectionLocked
                )
                if viewModel.isTemperatureSelectionLocked {
                    Text(LocalizedStringKey("noAlternativeOptions"))
                        .captionTextStyle()
                }
            } else {
                // Fixer parameters
                ParameterRow(
                    label: LocalizedStringKey("film"),
                    value: viewModel.selectedFilm?.name ?? String(localized: "selectFilm"),
                    onTap: { viewModel.showFilmPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: LocalizedStringKey("fixer"),
                    value: viewModel.selectedFixer?.name ?? String(localized: "selectFixer"),
                    onTap: { viewModel.showFixerPicker = true },
                    isDisabled: false
                )
                
                ParameterRow(
                    label: LocalizedStringKey("temperature"),
                    value: "\(viewModel.temperature)\(LocalizedStringKey("StandardC"))",
                    onTap: { viewModel.showTemperaturePicker = true },
                    isDisabled: false
                )
                
               
            }
        }
        .padding(.horizontal, 20)
    }
}
