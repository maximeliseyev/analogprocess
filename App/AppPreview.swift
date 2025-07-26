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

// MARK: - Preview Provider
struct AppPreview_Previews: PreviewProvider {
    static var previews: some View {
        AppPreview()
            .previewDisplayName("Main App")
    }
} 