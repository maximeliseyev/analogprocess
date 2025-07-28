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
