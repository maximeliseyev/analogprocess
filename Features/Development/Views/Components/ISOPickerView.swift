//
//  ISOPickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ISOPickerView: View {
    @Binding var iso: Int
    let onDismiss: () -> Void
    let availableISOs: [Int]
    @Environment(\.theme) private var theme
    
    private let allISOs = [25, 50, 64, 80, 100, 125, 200, 250, 400, 500, 640, 800, 1000, 1600, 2000, 3200, 4000, 6400, 8000, 12800 ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.primaryBackground.ignoresSafeArea()
                
                Group {
                if availableISOs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "info.circle")
                            .infoIconStyle()
                        
                        Text(LocalizedStringKey("noISOOptionsAvailable"))
                            .font(.headline)
                            .foregroundColor(theme.primaryText)
                        
                        Text(LocalizedStringKey("noISOOptionsDescription"))
                            .disabledTextStyle()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(allISOs, id: \.self) { isoValue in
                        let isAvailable = availableISOs.contains(isoValue)
                        
                        Button(action: {
                            if isAvailable {
                                iso = isoValue
                                onDismiss()
                            }
                        }) {
                            HStack {
                                Text(String(format: String(localized: "isoLabel"), "\(isoValue)"))
                                    .primaryTextStyle()
                                    .foregroundColor(isAvailable ? theme.primaryText : theme.secondaryText)
                                
                                Spacer()
                                
                                if iso == isoValue {
                                    Image(systemName: "checkmark")
                                        .checkmarkStyle()
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!isAvailable)
                    }
                }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedStringKey("selectISO"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct ISOPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ISOPickerView(
                iso: .constant(400),
                onDismiss: {},
                availableISOs: [100, 200, 400, 800]
            )
            
            ISOPickerView(
                iso: .constant(400),
                onDismiss: {},
                availableISOs: []
            )
        }
    }
} 