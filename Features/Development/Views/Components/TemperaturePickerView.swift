//
//  TemperaturePickerView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TemperaturePickerView: View {
    @Binding var temperature: Int
    let onDismiss: () -> Void

    
    private let temperatures = Array(15...30)
    
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
                            Text("\(temp)\(String(localized: "degreesCelsius"))")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if temperature == temp {
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
    }
    }


struct TemperaturePickerView_Previews: PreviewProvider {
    static var previews: some View {
        TemperaturePickerView(
            temperature: .constant(20),
            onDismiss: {}
        )
    }
} 
