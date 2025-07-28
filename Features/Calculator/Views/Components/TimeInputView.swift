//
//  TimeInputView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct TimeInputView: View {
    @Binding var minutes: String
    @Binding var seconds: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("basicTimeLabel"))
                .font(.headline)
            
            HStack {
                TextField(LocalizedStringKey("minutes"), text: $minutes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text(LocalizedStringKey("min"))
                
                TextField(LocalizedStringKey("seconds"), text: $seconds)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text(LocalizedStringKey("sec"))
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