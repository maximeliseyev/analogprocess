//
//  AppPreview.swift
//  FilmClaculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

// MARK: - Main App Preview
struct AppPreview: View {
    var body: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Development Setup Preview
struct DevelopmentSetupPreview: View {
    var body: some View {
        DevelopmentSetupView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Calculator Preview
struct CalculatorPreview: View {
    var body: some View {
        CalculatorView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Journal Preview
struct JournalPreview: View {
    @State private var records: [CalculationRecord] = []
    
    var body: some View {
        JournalView(
            records: records,
            onLoadRecord: { record in
                print("Loading record: \(record)")
            },
            onDeleteRecord: { record in
                print("Deleting record: \(record)")
            },
            onClose: {
                print("Closing journal")
            }
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .onAppear {
            // Загружаем тестовые записи для предварительного просмотра
            loadPreviewRecords()
        }
    }
    
    private func loadPreviewRecords() {
        let context = PersistenceController.preview.container.viewContext
        
        // Создаем тестовые записи
        let record1 = CalculationRecord(context: context)
        record1.filmName = "Kodak Tri-X 400"
        record1.developerName = "D-76"
        record1.dilution = "1:1"
        record1.iso = 400
        record1.temperature = 20.0
        record1.time = 480 // 8 минут
        record1.date = Date()
        
        let record2 = CalculationRecord(context: context)
        record2.filmName = "Ilford HP5 Plus"
        record2.developerName = "Rodinal"
        record2.dilution = "1:25"
        record2.iso = 400
        record2.temperature = 20.0
        record2.time = 600 // 10 минут
        record2.date = Date().addingTimeInterval(-86400) // Вчера
        
        records = [record1, record2]
    }
}

// MARK: - Timer Preview
struct TimerPreview: View {
    var body: some View {
        TimerView(
            timerLabel: "Проявка Kodak Tri-X 400",
            totalMinutes: 8,
            totalSeconds: 30,
            onClose: {
                print("Timer closed")
            }
        )
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

// MARK: - Preview Providers
struct AppPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Основной предварительный просмотр приложения
            AppPreview()
                .previewDisplayName("Main App")
            
            // Предварительный просмотр экрана настройки проявки
            DevelopmentSetupPreview()
                .previewDisplayName("Development Setup")
            
            // Предварительный просмотр калькулятора
            CalculatorPreview()
                .previewDisplayName("Calculator")
            
            // Предварительный просмотр журнала
            JournalPreview()
                .previewDisplayName("Journal")
            
            // Предварительный просмотр таймера
            TimerPreview()
                .previewDisplayName("Timer")
        }
    }
}

// MARK: - Individual Feature Previews
struct DevelopmentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        DevelopmentSetupPreview()
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorPreview()
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalPreview()
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerPreview()
    }
} 