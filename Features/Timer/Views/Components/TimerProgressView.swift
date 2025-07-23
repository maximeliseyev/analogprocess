//
//  TimerProgressView.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct TimerProgressView: View {
    let progress: Double
    let displayMinutes: Int
    let displaySeconds: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.3)
                .foregroundColor(.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            VStack(spacing: 8) {
                Text("\(displayMinutes):\(String(format: "%02d", displaySeconds))")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 250, height: 250)
    }
}

struct TimerProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TimerProgressView(
                progress: 0.3,
                displayMinutes: 5,
                displaySeconds: 45
            )
            
            TimerProgressView(
                progress: 0.7,
                displayMinutes: 2,
                displaySeconds: 15
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 