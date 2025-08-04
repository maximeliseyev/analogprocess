//
//  ThemeManager.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI

// MARK: - Theme Manager
@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var colorScheme: ColorScheme? = nil
    
    init() {}
    
    // MARK: - Background Colors
    var primaryBackground: Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        case nil:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    var secondaryBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.1)
        case .dark:
            return Color.gray.opacity(0.1)
        case nil:
            return Color.gray.opacity(0.1)
        @unknown default:
            return Color.gray.opacity(0.1)
        }
    }
    
    var cardBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.1)
        case .dark:
            return Color.gray.opacity(0.1)
        case nil:
            return Color.gray.opacity(0.1)
        @unknown default:
            return Color.gray.opacity(0.1)
        }
    }
    
    var parameterCardBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.2)
        case .dark:
            return Color.gray.opacity(0.3)
        case nil:
            return Color.gray.opacity(0.2)
        @unknown default:
            return Color.gray.opacity(0.2)
        }
    }
    
    // MARK: - Text Colors
    var primaryText: Color {
        switch colorScheme {
        case .light:
            return Color.black
        case .dark:
            return Color.white
        case nil:
            return Color.black
        @unknown default:
            return Color.black
        }
    }
    
    var secondaryText: Color {
        switch colorScheme {
        case .light:
            return Color.gray
        case .dark:
            return Color.gray
        case nil:
            return Color.gray
        @unknown default:
            return Color.gray
        }
    }
    
    var captionText: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.7)
        case .dark:
            return Color.gray
        case nil:
            return Color.gray.opacity(0.7)
        @unknown default:
            return Color.gray.opacity(0.7)
        }
    }
    
    // MARK: - Accent Colors
    var primaryAccent: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var secondaryAccent: Color {
        switch colorScheme {
        case .light:
            return Color.orange
        case .dark:
            return Color.orange
        case nil:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
    
    var successAccent: Color {
        switch colorScheme {
        case .light:
            return Color.green
        case .dark:
            return Color.green
        case nil:
            return Color.green
        @unknown default:
            return Color.green
        }
    }
    
    var warningAccent: Color {
        switch colorScheme {
        case .light:
            return Color.orange
        case .dark:
            return Color.orange
        case nil:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
    
    var dangerAccent: Color {
        switch colorScheme {
        case .light:
            return Color.red
        case .dark:
            return Color.red
        case nil:
            return Color.red
        @unknown default:
            return Color.red
        }
    }
    
    var purpleAccent: Color {
        switch colorScheme {
        case .light:
            return Color.purple
        case .dark:
            return Color.purple
        case nil:
            return Color.purple
        @unknown default:
            return Color.purple
        }
    }
    
    // MARK: - Button Colors
    var primaryButtonBackground: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var primaryButtonText: Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.white
        case nil:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    var secondaryButtonBackground: Color {
        switch colorScheme {
        case .light:
            return Color.green
        case .dark:
            return Color.green
        case nil:
            return Color.green
        @unknown default:
            return Color.green
        }
    }
    
    var secondaryButtonText: Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.white
        case nil:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    // MARK: - Selection Colors
    var selectionBackground: Color {
        switch colorScheme {
        case .light:
            return Color.blue.opacity(0.15)
        case .dark:
            return Color.blue.opacity(0.15)
        case nil:
            return Color.blue.opacity(0.15)
        @unknown default:
            return Color.blue.opacity(0.15)
        }
    }
    
    var selectionBorder: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    // MARK: - Timer Colors
    var timerActiveBackground: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var timerInactiveBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.3)
        case .dark:
            return Color.gray.opacity(0.3)
        case nil:
            return Color.gray.opacity(0.3)
        @unknown default:
            return Color.gray.opacity(0.3)
        }
    }
    
    var agitationBackground: Color {
        switch colorScheme {
        case .light:
            return Color.orange
        case .dark:
            return Color.orange
        case nil:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
}

// MARK: - Theme Environment Key
struct ThemeKey: EnvironmentKey {
    static let defaultValue = NonIsolatedThemeManager()
}

// MARK: - Non-Isolated Theme Manager for Environment
class NonIsolatedThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme? = nil
    
    var primaryBackground: Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        case nil:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    var secondaryBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.1)
        case .dark:
            return Color.gray.opacity(0.1)
        case nil:
            return Color.gray.opacity(0.1)
        @unknown default:
            return Color.gray.opacity(0.1)
        }
    }
    
    var cardBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.1)
        case .dark:
            return Color.gray.opacity(0.1)
        case nil:
            return Color.gray.opacity(0.1)
        @unknown default:
            return Color.gray.opacity(0.1)
        }
    }
    
    var parameterCardBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.2)
        case .dark:
            return Color.gray.opacity(0.3)
        case nil:
            return Color.gray.opacity(0.2)
        @unknown default:
            return Color.gray.opacity(0.2)
        }
    }
    
    var primaryText: Color {
        switch colorScheme {
        case .light:
            return Color.black
        case .dark:
            return Color.white
        case nil:
            return Color.black
        @unknown default:
            return Color.black
        }
    }
    
    var secondaryText: Color {
        switch colorScheme {
        case .light:
            return Color.gray
        case .dark:
            return Color.gray
        case nil:
            return Color.gray
        @unknown default:
            return Color.gray
        }
    }
    
    var captionText: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.7)
        case .dark:
            return Color.gray
        case nil:
            return Color.gray.opacity(0.7)
        @unknown default:
            return Color.gray.opacity(0.7)
        }
    }
    
    var primaryAccent: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var secondaryAccent: Color {
        switch colorScheme {
        case .light:
            return Color.orange
        case .dark:
            return Color.orange
        case nil:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
    
    var successAccent: Color {
        switch colorScheme {
        case .light:
            return Color.green
        case .dark:
            return Color.green
        case nil:
            return Color.green
        @unknown default:
            return Color.green
        }
    }
    
    var warningAccent: Color {
        switch colorScheme {
        case .light:
            return Color.orange
        case .dark:
            return Color.orange
        case nil:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
    
    var dangerAccent: Color {
        switch colorScheme {
        case .light:
            return Color.red
        case .dark:
            return Color.red
        case nil:
            return Color.red
        @unknown default:
            return Color.red
        }
    }
    
    var purpleAccent: Color {
        switch colorScheme {
        case .light:
            return Color.purple
        case .dark:
            return Color.purple
        case nil:
            return Color.purple
        @unknown default:
            return Color.purple
        }
    }
    
    var primaryButtonBackground: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var primaryButtonText: Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.white
        case nil:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    var secondaryButtonBackground: Color {
        switch colorScheme {
        case .light:
            return Color.green
        case .dark:
            return Color.green
        case nil:
            return Color.green
        @unknown default:
            return Color.green
        }
    }
    
    var secondaryButtonText: Color {
        switch colorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.white
        case nil:
            return Color.white
        @unknown default:
            return Color.white
        }
    }
    
    var selectionBackground: Color {
        switch colorScheme {
        case .light:
            return Color.blue.opacity(0.15)
        case .dark:
            return Color.blue.opacity(0.15)
        case nil:
            return Color.blue.opacity(0.15)
        @unknown default:
            return Color.blue.opacity(0.15)
        }
    }
    
    var selectionBorder: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var timerActiveBackground: Color {
        switch colorScheme {
        case .light:
            return Color.blue
        case .dark:
            return Color.blue
        case nil:
            return Color.blue
        @unknown default:
            return Color.blue
        }
    }
    
    var timerInactiveBackground: Color {
        switch colorScheme {
        case .light:
            return Color.gray.opacity(0.3)
        case .dark:
            return Color.gray.opacity(0.3)
        case nil:
            return Color.gray.opacity(0.3)
        @unknown default:
            return Color.gray.opacity(0.3)
        }
    }
    
    var agitationBackground: Color {
        switch colorScheme {
        case .light:
            return Color.orange
        case .dark:
            return Color.orange
        case nil:
            return Color.orange
        @unknown default:
            return Color.orange
        }
    }
}

extension EnvironmentValues {
    var theme: NonIsolatedThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
} 