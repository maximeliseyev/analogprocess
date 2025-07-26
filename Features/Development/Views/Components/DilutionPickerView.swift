//
//  DilutionPickerView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

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
                        
                        Text(LocalizedStringKey("noDilutionsAvailable"))
                            .font(.headline)
                        
                        Text(LocalizedStringKey("noDilutionsDescription"))
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
            .navigationTitle(LocalizedStringKey("selectDilution"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
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
                onDismiss: {}
            )
            
            DilutionPickerView(
                dilutions: [],
                selectedDilution: .constant(""),
                onDismiss: {}
            )
        }
    }
} 