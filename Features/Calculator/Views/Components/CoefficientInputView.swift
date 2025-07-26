//
//  CoefficientInputView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct CoefficientInputView: View {
    @Binding var coefficient: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("coefficient"))
                .font(.headline)
            
            HStack {
                TextField("1.33", text: $coefficient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text(LocalizedStringKey("standardCoefficient"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct CoefficientInputView_Previews: PreviewProvider {
    static var previews: some View {
        CoefficientInputView(coefficient: .constant("1.33"))
            .padding()
    }
} 