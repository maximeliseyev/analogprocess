//
//  TimerTabView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerTabView: View {
    @State private var navigateToTimer = false
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var timerLabel = ""
    @State private var showManualTimeInput = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text(LocalizedStringKey("selectDevelopmentParameters"))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Показываем текущее время
            VStack(spacing: 15) {
                Button(action: {
                    showManualTimeInput = true
                }) {
                    VStack(spacing: 5) {
                        Text("\(timerMinutes):\(String(format: "%02d", timerSeconds))")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        
                        Text(LocalizedStringKey("tapToChangeTime"))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Button(action: {
                navigateToTimer = true
            }) {
                HStack {
                    Image(systemName: "timer")
                        .font(.title2)
                    Text(LocalizedStringKey("startTimer"))
                        .font(.headline)
                }
                .foregroundColor(timerMinutes == 0 && timerSeconds == 0 ? .gray : .white)
                .padding()
                .background(timerMinutes == 0 && timerSeconds == 0 ? Color.gray.opacity(0.3) : Color.blue)
                .cornerRadius(10)
            }
            .disabled(timerMinutes == 0 && timerSeconds == 0)
            
            if timerMinutes == 0 && timerSeconds == 0 {
                Text(LocalizedStringKey("set_time_to_start_timer"))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .padding()
        .navigationTitle(LocalizedStringKey("timer"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToTimer) {
            TimerView(
                timerLabel: timerLabel.isEmpty ? "Development Timer" : timerLabel,
                totalMinutes: timerMinutes,
                totalSeconds: timerSeconds
            )
        }
        .sheet(isPresented: $showManualTimeInput) {
            ManualTimeInputView(
                minutes: $timerMinutes,
                seconds: $timerSeconds,
                onApply: {
                    showManualTimeInput = false
                },
                onCancel: {
                    showManualTimeInput = false
                }
            )
            .presentationDetents([.medium])
        }
    }
}

// MARK: - Previews

struct TimerTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimerTabView()
        }
        .preferredColorScheme(.dark)
    }
}
