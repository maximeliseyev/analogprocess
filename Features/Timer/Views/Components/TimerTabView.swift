//
//  TimerTabView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerTabView: View {
    @State private var showTimer = false
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var timerLabel = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text(LocalizedStringKey("selectDevelopmentParameters"))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    showTimer = true
                }) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.title2)
                        Text(LocalizedStringKey("startTimer"))
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .padding()
            .navigationTitle(LocalizedStringKey("timer"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTimer) {
                TimerView(
                    timerLabel: timerLabel.isEmpty ? "Development Timer" : timerLabel,
                    totalMinutes: timerMinutes,
                    totalSeconds: timerSeconds
                )
            }
        }
    }
}
