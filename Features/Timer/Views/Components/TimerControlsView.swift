//
//  TimerControlsView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerControlsView: View {
    let isRunning: Bool
    let onStartPause: () -> Void
    let onReset: () -> Void
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 30) {
            Button(action: onStartPause) {
                HStack {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                    Text(isRunning ? LocalizedStringKey("pause") : LocalizedStringKey("start"))
                }
                .font(.headline)
                .foregroundColor(theme.primaryButtonText)
                .frame(width: 120, height: 50)
                .background(isRunning ? theme.agitationBackground : theme.successAccent)
                .cornerRadius(25)
            }
            
            Button(action: onReset) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(LocalizedStringKey("reset"))
                }
                .font(.headline)
                .foregroundColor(theme.primaryButtonText)
                .frame(width: 120, height: 50)
                .background(theme.secondaryText)
                .cornerRadius(25)
            }
        }
    }
}

struct TimerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TimerControlsView(
                isRunning: false,
                onStartPause: {},
                onReset: {}
            )
            
            TimerControlsView(
                isRunning: true,
                onStartPause: {},
                onReset: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 