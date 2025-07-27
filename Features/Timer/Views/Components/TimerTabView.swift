//
//  TimerTabView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 26.07.2025.
//


import SwiftUI
import CoreData

public struct TimerTabView: View {
    @State private var showTimer = false
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var timerLabel = ""
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text(LocalizedStringKey("selectDevelopmentParameters"))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    // Здесь можно добавить логику для настройки таймера
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
                    totalSeconds: timerSeconds,
                    onClose: { showTimer = false }
                )
            }
        }
    }
    
    public init() {}
}
