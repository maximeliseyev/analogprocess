//
//  CustomAgitationView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CustomAgitationView: View {
    @Binding var agitationMode: AgitationMode
    let onDismiss: () -> Void
    
    @State private var agitationSeconds: Int = 15
    @State private var restSeconds: Int = 45
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Agitation Time")
                        .font(.headline)
                    
                    Stepper(value: $agitationSeconds, in: 1...60) {
                        Text("\(agitationSeconds) seconds")
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rest Time")
                        .font(.headline)
                    
                    Stepper(value: $restSeconds, in: 0...180) {
                        Text("\(restSeconds) seconds")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preview")
                        .font(.headline)
                    
                    Text("Cycle: \(agitationSeconds)s agitation → \(restSeconds)s rest")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text("Total cycle duration: \(agitationSeconds + restSeconds)s")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Agitation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        agitationMode = AgitationMode.createCustomMode(agitationSeconds: agitationSeconds, restSeconds: restSeconds)
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct CustomAgitationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAgitationView(
            agitationMode: .constant(AgitationMode.presets[0]),
            onDismiss: {}
        )
    }
}

