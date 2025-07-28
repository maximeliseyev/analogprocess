//
//  CustomAgitationView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CustomAgitationView: View {
    @State private var agitationSeconds: Int = 15
    @State private var restSeconds: Int = 45
    
    let onSelect: (AgitationMode) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text(LocalizedStringKey("customAgitationSetup"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text(LocalizedStringKey("customAgitationSetupDescription"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizedStringKey("agitationTime"))
                            .font(.headline)
                        
                        HStack {
                            Stepper(value: $agitationSeconds, in: 1...60) {
                                HStack {
                                    Text("\(agitationSeconds)")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .frame(width: 40)
                                    
                                    Text(LocalizedStringKey("seconds"))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(LocalizedStringKey("restTime"))
                            .font(.headline)
                        
                        HStack {
                            Stepper(value: $restSeconds, in: 0...180) {
                                HStack {
                                    Text("\(restSeconds)")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .frame(width: 40)
                                    
                                    Text(LocalizedStringKey("seconds"))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey("preview"))
                            .font(.headline)
                        
                        Text("\(LocalizedStringKey("cycle")): \(agitationSeconds)с ажитации → \(restSeconds)с покоя")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Text("\(LocalizedStringKey("totalCycleDuration")): \(agitationSeconds + restSeconds)с")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(LocalizedStringKey("createMode")) {
                    let customMode = AgitationMode.createCustomMode(
                        agitationSeconds: agitationSeconds,
                        restSeconds: restSeconds
                    )
                    onSelect(customMode)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("cancel")) {
                        onCancel()
                    }
                }
            }
        }
    }
}

struct CustomAgitationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomAgitationView(
            onSelect: { _ in },
            onCancel: {}
        )
    }
}