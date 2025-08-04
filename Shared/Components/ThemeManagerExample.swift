//
//  ThemeManagerExample.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// MARK: - Example View Using ThemeManager
struct ThemeManagerExampleView: View {
    @Environment(\.theme) private var theme
    @State private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Пример использования цветов темы
                    VStack(spacing: 16) {
                        Text("Theme Manager Demo")
                            .font(.title)
                            .foregroundColor(theme.primaryText)
                        
                        Text("This demonstrates the centralized theme management")
                            .font(.body)
                            .foregroundColor(theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(theme.cardBackground)
                    .cornerRadius(12)
                    
                    // Примеры кнопок
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
                    
                    // Примеры цветов акцентов
                    VStack(spacing: 8) {
                        HStack {
                            Circle()
                                .fill(theme.primaryAccent)
                                .frame(width: 20, height: 20)
                            Text("Primary Accent")
                                .foregroundColor(theme.primaryText)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.successAccent)
                                .frame(width: 20, height: 20)
                            Text("Success Accent")
                                .foregroundColor(theme.primaryText)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.warningAccent)
                                .frame(width: 20, height: 20)
                            Text("Warning Accent")
                                .foregroundColor(theme.primaryText)
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.dangerAccent)
                                .frame(width: 20, height: 20)
                            Text("Danger Accent")
                                .foregroundColor(theme.primaryText)
                        }
                    }
                    .padding()
                    .background(theme.parameterCardBackground)
                    .cornerRadius(12)
                    
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
            .navigationTitle("Theme Manager")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview
struct ThemeManagerExampleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ThemeManagerExampleView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ThemeManagerExampleView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
} 