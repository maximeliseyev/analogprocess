//
//  ISOPickerView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ISOPickerView: View {
    @Binding var iso: Int
    let onDismiss: () -> Void
    
    private let availableISOs = [50, 100, 125, 200, 250, 400, 500, 800, 1600, 3200, 6400]
    
    var body: some View {
        NavigationView {
            List(availableISOs, id: \.self) { isoValue in
                Button(action: {
                    iso = isoValue
                    onDismiss()
                }) {
                    HStack {
                        Text("ISO \(isoValue)")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if iso == isoValue {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Выберите ISO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct ISOPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ISOPickerView(
            iso: .constant(400),
            onDismiss: {}
        )
    }
} 