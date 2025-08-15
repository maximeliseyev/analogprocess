//
//  FilmLabApp.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import SwiftData

@main
struct AnalogProcessApp: App {
    let swiftDataPersistence = SwiftDataPersistence.shared
    @State private var colorScheme: ColorScheme? = nil
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var autoSyncService = AutoSyncService.shared

    var body: some Scene {
        WindowGroup {
            ContentView(colorScheme: $colorScheme)
                .modelContainer(swiftDataPersistence.modelContainer)
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
}
