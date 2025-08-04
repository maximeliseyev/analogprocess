//
//  FilmLabApp.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import CoreData

@main
struct FilmLabApp: App {
    let persistenceController = PersistenceController.shared
    @State private var colorScheme: ColorScheme? = nil
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView(colorScheme: $colorScheme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
                }
                .onChange(of: colorScheme) { _, newValue in
                    Task { @MainActor in
                        themeManager.colorScheme = newValue
                    }
                }
        }
    }
}
