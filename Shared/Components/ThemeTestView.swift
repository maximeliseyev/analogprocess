//
//  ThemeTestView.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

struct ThemeTestView: View {
    @Environment(\.theme) private var theme
    @State private var isDarkMode = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Theme Test")
                        .font(.title)
                        .foregroundColor(theme.primaryText)
                    
                    Text("Current theme: \(isDarkMode ? "Dark" : "Light")")
                        .font(.body)
                        .foregroundColor(theme.secondaryText)
                    
                    // Тест цветов
                    VStack(spacing: 10) {
                        HStack {
                            Circle()
                                .fill(theme.primaryBackground)
                                .frame(width: 30, height: 30)
                            Text("Primary Background")
                                .foregroundColor(theme.primaryText)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.cardBackground)
                                .frame(width: 30, height: 30)
                            Text("Card Background")
                                .foregroundColor(theme.primaryText)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.primaryAccent)
                                .frame(width: 30, height: 30)
                            Text("Primary Accent")
                                .foregroundColor(theme.primaryText)
                        }
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(12)
                    
                    // Кнопки
                    VStack(spacing: 12) {
                        Button("Primary Button") {
                            // Action
                        }
                        .primaryButtonStyle()
                        
                        Button("Secondary Button") {
                            // Action
                        }
                        .secondaryButtonStyle()
                    }
                    
                    // Переключатель темы
                    Toggle("Dark Mode", isOn: $isDarkMode)
                        .foregroundColor(theme.primaryText)
                        .padding()
                        .background(theme.cardBackground)
                        .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Theme Test")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ThemeTestView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ThemeTestView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            ThemeTestView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
        }
    }
} 