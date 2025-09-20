//
//  CoefficientInputView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct RatioInputView: View {
    @Binding var ratio: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("ratio"))
                .font(.headline)
            
            HStack {
                TextField("1.33", text: $ratio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: ratio) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        let components = filtered.components(separatedBy: ".")

                        if components.count > 2 {
                            let reconstructed = components[0] + "." + components[1]
                            ratio = String(reconstructed.prefix(4))
                        } else if let doubleValue = Double(filtered) {
                            if doubleValue > 5.0 {
                                ratio = "5.0"
                            } else if doubleValue < 0.1 {
                                ratio = "0.1"
                            } else {
                                ratio = String(filtered.prefix(4))
                            }
                        } else if filtered.isEmpty {
                            ratio = ""
                        } else {
                            ratio = String(filtered.prefix(4))
                        }
                    }

                Text(LocalizedStringKey("standardRatio"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct RatioInputView_Previews: PreviewProvider {
    static var previews: some View {
        RatioInputView(ratio: .constant("1.33"))
            .padding()
    }
} 
