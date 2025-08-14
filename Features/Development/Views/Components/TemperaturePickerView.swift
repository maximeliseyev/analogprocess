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
            ZStack {
                Color.clear.ignoresSafeArea()
                
                List(temperatures, id: \.self) { temp in
                    Button(action: {
                        temperature = temp
                        onDismiss()
                    }) {
                        HStack {
                            Text("\(temp, specifier: "%.1f")\(String(localized: "degreesCelsius"))")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if abs(temperature - temp) < 0.1 {
                                Image(systemName: "checkmark")
                                    .checkmarkStyle()
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
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
        .overlay(
            Group {
                // если выбора нет (только одна температура в данных) — блокируем взаимодействие прозрачной маской
                if temperatures.count <= 1 {
                    Color.black.opacity(0.0001)
                }
            }
        )
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
