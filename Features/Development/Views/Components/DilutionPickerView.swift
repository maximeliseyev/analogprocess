//
//  DilutionPickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct DilutionPickerView: View {
    let dilutions: [String]
    @Binding var selectedDilution: String
    let onDismiss: () -> Void
    let isDisabled: Bool
    let onDilutionSelected: ((String) -> Void)?

    
        var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                Group {
                if dilutions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "info.circle")
                            .infoIconStyle()
                        
                        Text(LocalizedStringKey("noDilutionsAvailable"))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(LocalizedStringKey("noDilutionsDescription"))
                            .disabledTextStyle()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(dilutions, id: \.self) { dilution in
                        Button(action: {
                            selectedDilution = dilution
                            onDilutionSelected?(dilution)
                            onDismiss()
                        }) {
                            HStack {
                                Text(dilution)
                                    .primaryTextStyle()
                                
                                Spacer()
                                
                                if selectedDilution == dilution {
                                    Image(systemName: "checkmark")
                                    .checkmarkStyle()
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isDisabled || dilutions.count <= 1)
                    }
                }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedStringKey("selectDilution"))
        }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }


struct DilutionPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DilutionPickerView(
                dilutions: ["1:1", "1:2", "1:4"],
                selectedDilution: .constant("1:1"),
                onDismiss: {},
                isDisabled: false,
                onDilutionSelected: { _ in }
            )
            
            DilutionPickerView(
                dilutions: [],
                selectedDilution: .constant(""),
                onDismiss: {},
                isDisabled: false,
                onDilutionSelected: { _ in }
            )
            
            DilutionPickerView(
                dilutions: [],
                selectedDilution: .constant(""),
                onDismiss: {},
                isDisabled: true,
                onDilutionSelected: { _ in }
            )
        }
    }
} 
