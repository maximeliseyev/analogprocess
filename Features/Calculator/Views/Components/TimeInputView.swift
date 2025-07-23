//
//  TimeInputView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct TimeInputView: View {
    @Binding var minutes: String
    @Binding var seconds: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Базовое время:")
                .font(.headline)
            
            HStack {
                TextField("Минуты", text: $minutes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("мин")
                
                TextField("Секунды", text: $seconds)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("сек")
            }
        }
    }
}

struct TimeInputView_Previews: PreviewProvider {
    static var previews: some View {
        TimeInputView(minutes: .constant("5"), seconds: .constant("30"))
            .padding()
    }
} 