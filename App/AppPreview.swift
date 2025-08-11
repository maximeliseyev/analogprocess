//
//  AppPreview.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import SwiftData


// MARK: - Main App Preview
struct AppPreview: View {
    @State private var colorScheme: ColorScheme? = nil
    
    var body: some View {
        ContentView(colorScheme: $colorScheme)
            .modelContainer(SwiftDataPersistence.preview.modelContainer)
    }
}

// MARK: - Preview Provider
struct AppPreview_Previews: PreviewProvider {
    static var previews: some View {
        AppPreview()
            .previewDisplayName("Main App")
    }
} 