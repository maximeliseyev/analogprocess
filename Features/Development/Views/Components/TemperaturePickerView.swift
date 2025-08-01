//
//  TemperaturePickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TemperaturePickerView: View {
    @Binding var temperature: Double
    let onDismiss: () -> Void
    
    private let temperatures = Array(stride(from: 15.0, through: 30.0, by: 0.5))
    
    var body: some View {
        NavigationStack {
            List(temperatures, id: \.self) { temp in
                Button(action: {
                    temperature = temp
                    onDismiss()
                }) {
                    HStack {
                        Text("\(temp, specifier: "%.1f")\(String(localized: "degreesCelsius"))")
                            .primaryTextStyle()
                        
                        Spacer()
                        
                        if abs(temperature - temp) < 0.1 {
                            Image(systemName: "checkmark")
                                .checkmarkStyle()
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(LocalizedStringKey("selectTemperature"))
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

struct TemperaturePickerView_Previews: PreviewProvider {
    static var previews: some View {
        TemperaturePickerView(
            temperature: .constant(20.0),
            onDismiss: {}
        )
    }
} 