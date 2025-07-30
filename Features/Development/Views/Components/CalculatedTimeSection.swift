//
//  CalculatedTimeSection.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CalculatedTimeSection: View {
    let time: Int
    let onCalculatorTap: () -> Void
    let onTimerTap: () -> Void
    
    private var minutes: Int {
        time / 60
    }
    
    private var seconds: Int {
        time % 60
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onCalculatorTap) {
                HStack {
                    Image(systemName: "plus.forwardslash.minus")
                        .font(.system(size: 18, design: .monospaced))
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.system(size: 18, design: .monospaced))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color.blue)
                .cornerRadius(12)
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onTimerTap) {
                HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 18, design: .monospaced))
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.system(size: 18, design: .monospaced))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color.green)
                .cornerRadius(12)
                .buttonStyle(PlainButtonStyle())
            }
                
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct CalculatedTimeSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CalculatedTimeSection(
                time: 450, // 7:30
                onCalculatorTap: {},
                onTimerTap: {}
            )
        }
    }
} 
