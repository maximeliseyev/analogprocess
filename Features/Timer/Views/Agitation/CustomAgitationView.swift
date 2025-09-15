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
                    Text(LocalizedStringKey("agitationTime"))
                        .font(.headline)
                    
                    Stepper(value: $agitationSeconds, in: 1...60) {
                        Text("\(agitationSeconds) \(String(localized: "seconds"))")
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(LocalizedStringKey("restTime"))
                        .font(.headline)
                    
                    Stepper(value: $restSeconds, in: 0...180) {
                        Text("\(restSeconds) \(String(localized: "seconds"))")
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("preview"))
                        .font(.headline)
                    
                    Text(String(format: String(localized: "cycleFormat"), "\(agitationSeconds)", "\(restSeconds)"))
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: String(localized: "totalCycleDuration"), "\(agitationSeconds + restSeconds)"))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle(LocalizedStringKey("customAgitationTitle"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizedStringKey("cancel")) {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("save")) {
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

