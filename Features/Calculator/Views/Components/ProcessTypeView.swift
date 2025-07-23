//
//  ProcessTypeView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

struct ProcessTypeView: View {
    @Binding var isPushMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Тип процесса:")
                .font(.headline)
            
            Picker("Тип процесса", selection: $isPushMode) {
                Text("PULL").tag(false)
                Text("PUSH").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct ProcessTypeView_Previews: PreviewProvider {
    static var previews: some View {
        ProcessTypeView(isPushMode: .constant(true))
            .padding()
    }
} 