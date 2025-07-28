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
            .navigationTitle(LocalizedStringKey("selectTemperature"))
            .navigationBarTitleDisplayMode(.inline)
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