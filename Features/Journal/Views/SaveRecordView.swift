//
//  SaveRecordView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUICore
import SwiftUI


struct SaveRecordView: View {
    @Binding var recordName: String
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Сохранить расчёт")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                TextField("Введите название", text: $recordName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        onSave()
                    }
                    .disabled(recordName.isEmpty)
                }
            }
        }
    }
}
