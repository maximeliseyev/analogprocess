//
//  SaveRecordView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct SaveRecordView: View {
    @Binding var recordName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(LocalizedStringKey("saveRecordDescription"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField(LocalizedStringKey("recordName"), text: $recordName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle(LocalizedStringKey("saveRecord"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
                        onSave()
                    }
                    .disabled(recordName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
