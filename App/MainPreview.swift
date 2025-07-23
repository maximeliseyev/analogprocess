//
//  MainPreview.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

// MARK: - Main Preview Container
struct MainPreview: View {
    @State private var selectedPreview = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Film develop calaculator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Text("Выберите экран для тестирования:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        PreviewCard(
                            title: "Основное приложение",
                            subtitle: "Полный функционал",
                            icon: "app.fill",
                            color: .blue
                        ) {
                            AppPreview()
                        }
                        
                        PreviewCard(
                            title: "Настройка проявки",
                            subtitle: "Выбор пленки и проявителя",
                            icon: "camera.aperture",
                            color: .green
                        ) {
                            DevelopmentSetupPreview()
                        }
                        
                        PreviewCard(
                            title: "Калькулятор",
                            subtitle: "Расчет времени",
                            icon: "timer",
                            color: .orange
                        ) {
                            CalculatorPreview()
                        }
                        
                        PreviewCard(
                            title: "Журнал",
                            subtitle: "Сохраненные записи",
                            icon: "book",
                            color: .purple
                        ) {
                            JournalPreview()
                        }
                        
                        PreviewCard(
                            title: "Таймер",
                            subtitle: "Таймер проявки",
                            icon: "clock",
                            color: .red
                        ) {
                            TimerPreview()
                        }
                        
                        PreviewCard(
                            title: "Компоненты",
                            subtitle: "UI компоненты",
                            icon: "rectangle.stack",
                            color: .gray
                        ) {
                            ComponentPreviews()
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Preview Card
struct PreviewCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: Content
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        @ViewBuilder destination: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.destination = destination()
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Component Previews Container
struct ComponentPreviews: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Group {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Parameter Row")
                            .font(.headline)
                        ParameterRowPreview()
                    }
                    

                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Record Row")
                            .font(.headline)
                        RecordRowPreview()
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Calculator Components")
                            .font(.headline)
                        CalculatorComponentsPreview()
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
        .navigationTitle("Компоненты")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Main Preview Provider
struct MainPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Основной предварительный просмотр
            MainPreview()
                .previewDisplayName("Main Preview")
            
            // Прямой доступ к основному приложению
            AppPreview()
                .previewDisplayName("Full App")
            
            // Прямой доступ к экрану настройки проявки
            DevelopmentSetupPreview()
                .previewDisplayName("Development Setup")
        }
    }
} 
