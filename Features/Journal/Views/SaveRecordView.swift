//
//  SaveRecordView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI


struct SaveRecordView: View {
    @Binding var recordName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(LocalizedStringKey("saveCalculation"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                TextField(LocalizedStringKey("recordName"), text: $recordName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }

            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("save")) {
                        onSave()
                    }
                    .disabled(recordName.isEmpty)
                }
            }
        }
    }
}
