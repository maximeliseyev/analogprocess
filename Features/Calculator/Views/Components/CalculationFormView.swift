//
//  CalculationFormView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct CalculationFormView: View {
    @Binding var minutes: String
    @Binding var seconds: String
    @Binding var coefficient: String
    @Binding var isPushMode: Bool
    @Binding var pushSteps: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TimeInputView(minutes: $minutes, seconds: $seconds)
            
            CoefficientInputView(coefficient: $coefficient)
            
            ProcessTypeView(isPushMode: $isPushMode)
            
            StepsInputView(pushSteps: $pushSteps, isPushMode: isPushMode)
        }
        .padding(.horizontal)
    }
}

struct CalculationFormView_Previews: PreviewProvider {
    static var previews: some View {
        CalculationFormView(
            minutes: .constant("5"),
            seconds: .constant("30"),
            coefficient: .constant("1.33"),
            isPushMode: .constant(true),
            pushSteps: .constant(3)
        )
        .padding()
    }
} 