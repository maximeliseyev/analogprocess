//
//  Film_claculatorApp.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import CoreData

@main
struct FilmClaculatorApp: App {
    let persistenceController = PersistenceController.shared
    @State private var colorScheme: ColorScheme? = nil

    var body: some Scene {
        WindowGroup {
            ContentView(colorScheme: $colorScheme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(colorScheme)
        }
    }
}
