//
//  FilmLabApp.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct AnalogProcessApp: App {
    @StateObject private var githubDataService: GitHubDataService
    @StateObject private var swiftDataService: SwiftDataService
    @StateObject private var autoSyncService: AutoSyncService
    
    private let modelContainer: ModelContainer

    @State private var colorScheme: ColorScheme? = nil
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        let persistence = SwiftDataPersistence()
        self.modelContainer = persistence.modelContainer
        
        let githubService = GitHubDataService()
        let swiftDataService = SwiftDataService(githubDataService: githubService, modelContainer: self.modelContainer)
        let autoSyncService = AutoSyncService(swiftDataService: swiftDataService, githubDataService: githubService)
        
        _githubDataService = StateObject(wrappedValue: githubService)
        _swiftDataService = StateObject(wrappedValue: swiftDataService)
        _autoSyncService = StateObject(wrappedValue: autoSyncService)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(colorScheme: $colorScheme)
                .modelContainer(modelContainer)
                .environmentObject(githubDataService)
                .environmentObject(swiftDataService)
                .environmentObject(autoSyncService)
                .environment(\.theme, NonIsolatedThemeManager())
                .preferredColorScheme(colorScheme)
                .onAppear {
                    // Устанавливаем темную тему по умолчанию
                    if colorScheme == nil {
                        colorScheme = .dark
                    }
                    
                    // Синхронизируем colorScheme с ThemeManager
                    Task { @MainActor in
                        themeManager.colorScheme = colorScheme
                    }
                    
                    // Создаем тестовые данные для CloudKit (только если их нет)
                    createTestDataIfNeeded()

                    // Запускаем автоматическую синхронизацию данных
                    autoSyncService.performAutoSyncOnAppLaunch()
                }
                .onChange(of: colorScheme) { _, newValue in
                    Task { @MainActor in
                        themeManager.colorScheme = newValue
                    }
                }
        }
    }

    private func createTestDataIfNeeded() {
        let modelContext = modelContainer.mainContext

        print("🧪 Creating test data for CloudKit...")

        // Проверяем, есть ли уже данные
        let filmDescriptor = FetchDescriptor<SwiftDataFilm>()
        if let existingFilms = try? modelContext.fetch(filmDescriptor), !existingFilms.isEmpty {
            print("📋 Test data already exists, skipping...")
            return
        }

        // Создаем тестовую пленку
        let testFilm = SwiftDataFilm()
        testFilm.name = "Kodak Tri-X 400"
        testFilm.manufacturer = "Kodak"
        testFilm.type = "Black & White"
        testFilm.defaultISO = 400

        // Создаем тестовый проявитель
        let testDeveloper = SwiftDataDeveloper()
        testDeveloper.name = "Kodak HC-110"
        testDeveloper.manufacturer = "Kodak"
        testDeveloper.type = "liquid"
        testDeveloper.defaultDilution = "1+31"

        // Создаем тестовую запись расчета
        let testRecord = SwiftDataCalculationRecord()
        testRecord.name = "Test Calculation"
        testRecord.filmName = "Kodak Tri-X 400"
        testRecord.developerName = "Kodak HC-110"
        testRecord.dilution = "1+31"
        testRecord.iso = 400
        testRecord.temperature = 20
        testRecord.time = 600
        testRecord.comment = "Test calculation for CloudKit sync"
        testRecord.date = Date()
        testRecord.lastModified = Date()

        // Создаем тестовый режим агитации
        let testAgitation = SwiftDataCustomAgitationMode()
        testAgitation.name = "Test Agitation Mode"
        testAgitation.firstMinuteAgitationType = "continuous"
        testAgitation.intermediateAgitationType = "cycle"
        testAgitation.intermediateAgitationSeconds = 10
        testAgitation.intermediateRestSeconds = 50

        // Добавляем в контекст
        modelContext.insert(testFilm)
        modelContext.insert(testDeveloper)
        modelContext.insert(testRecord)
        modelContext.insert(testAgitation)

        // Сохраняем
        do {
            try modelContext.save()
            print("✅ Test data created successfully!")
            print("📊 Created: 1 film, 1 developer, 1 record, 1 agitation mode")
            print("☁️ Data should now appear in CloudKit Console after sync...")
        } catch {
            print("❌ Failed to save test data: \(error)")
        }
    }
}
