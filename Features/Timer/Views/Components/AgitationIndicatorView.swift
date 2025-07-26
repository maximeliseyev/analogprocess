//
//  AgitationIndicatorView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import Foundation

struct AgitationIndicatorView: View {
    let shouldAgitate: Bool
    let selectedAgitationMode: AgitationMode?
    let isInAgitationPhase: Bool
    let agitationTimeRemaining: Int
    let currentMinute: Int
    let currentAgitationPhase: AgitationMode.PhaseAgitationType?
    
    var body: some View {
        if shouldAgitate && selectedAgitationMode != nil {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(isInAgitationPhase ? .orange : .blue)
                        .font(.title2)
                    
                    Text(isInAgitationPhase ? LocalizedStringKey("agitation") : LocalizedStringKey("rest"))
                        .font(.headline)
                        .foregroundColor(isInAgitationPhase ? .orange : .blue)
                        .fontWeight(.bold)
                    
                    if agitationTimeRemaining > 0 {
                        Text("(\(agitationTimeRemaining)с)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isInAgitationPhase ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                .cornerRadius(20)
                
                VStack(spacing: 4) {
                    Text("Minute \(currentMinute)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let phase = currentAgitationPhase {
                        Text(getPhaseDescription(phase))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
    
    private func getPhaseDescription(_ phase: AgitationMode.PhaseAgitationType) -> String {
        switch phase {
        case .continuous:
            return "Непрерывная ажитация"
        case .cycle(let agitation, let rest):
            return "\(agitation)с ажитации / \(rest)с покоя"
        case .periodic(let interval):
            return "Каждые \(interval)с"
        case .custom(let description):
            return description
        }
    }
}

struct AgitationIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AgitationIndicatorView(
                shouldAgitate: true,
                selectedAgitationMode: nil,
                isInAgitationPhase: true,
                agitationTimeRemaining: 30,
                currentMinute: 1,
                currentAgitationPhase: .continuous
            )
            
            AgitationIndicatorView(
                shouldAgitate: true,
                selectedAgitationMode: nil,
                isInAgitationPhase: false,
                agitationTimeRemaining: 15,
                currentMinute: 2,
                currentAgitationPhase: .cycle(agitationSeconds: 30, restSeconds: 15)
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 