//
//  Film_claculatorApp.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

@main
struct FilmClaculatorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DevelopmentSetupView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
