//
//  CalculatedTimeSection.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct CalculatedTimeSection: View {
    let time: Int
    let onTap: () -> Void
    
    private var minutes: Int {
        time / 60
    }
    
    private var seconds: Int {
        time % 60
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Время проявки")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: onTap) {
                VStack(spacing: 8) {
                    Text("\(minutes):\(String(format: "%02d", seconds))")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    Text("Нажмите для перехода к калькулятору")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.blue, lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct CalculatedTimeSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CalculatedTimeSection(
                time: 480, // 8 минут
                onTap: {}
            )
        }
    }
} 