import SwiftUI

// MARK: - Navigation Constants
enum NavigationConstants {
    // Tab indices
    static let homeTab = 0
    static let presetsTab = 1
    static let calculatorTab = 2
    static let timerTab = 3
    static let journalTab = 4
    
    static let tabCount = 5
    
    // Localization keys
    static let mainTitleKey = "main_title"
    static let homeDescriptionKey = "home_description"
    
    // Navigation button indices
    static let presetsButtonIndex = 0
    static let calculatorButtonIndex = 1
    static let timerButtonIndex = 2
    static let journalButtonIndex = 3
}

// MARK: - Navigation Button Data
struct NavigationButtonData {
    let index: Int
    let titleKey: String
    let subtitleKey: String
    let iconName: String
    let iconColor: Color
    
    static let allButtons: [NavigationButtonData] = [
        NavigationButtonData(
            index: NavigationConstants.presetsButtonIndex,
            titleKey: "presets",
            subtitleKey: "home_presets_subtitle",
            iconName: "slider.horizontal.3",
            iconColor: .blue
        ),
        NavigationButtonData(
            index: NavigationConstants.calculatorButtonIndex,
            titleKey: "calculator",
            subtitleKey: "home_calculator_subtitle",
            iconName: "plus.forwardslash.minus",
            iconColor: .orange
        ),
        NavigationButtonData(
            index: NavigationConstants.timerButtonIndex,
            titleKey: "timer",
            subtitleKey: "home_timer_subtitle",
            iconName: "timer",
            iconColor: .red
        ),
        NavigationButtonData(
            index: NavigationConstants.journalButtonIndex,
            titleKey: "journal",
            subtitleKey: "home_journal_subtitle",
            iconName: "book",
            iconColor: .purple
        )
    ]
} 