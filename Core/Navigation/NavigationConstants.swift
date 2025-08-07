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
    static let mainTitleKey = "mainTitle"
    static let homeDescriptionKey = "homeDescription"
    
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
            subtitleKey: "homePresetsSubtitle",
            iconName: "slider.horizontal.3",
            iconColor: .blue
        ),
        NavigationButtonData(
            index: NavigationConstants.calculatorButtonIndex,
            titleKey: "calculator",
            subtitleKey: "homeCalculatorSubtitle",
            iconName: "plus.forwardslash.minus",
            iconColor: .orange
        ),
        NavigationButtonData(
            index: NavigationConstants.timerButtonIndex,
            titleKey: "timer",
            subtitleKey: "homeTimerSubtitle",
            iconName: "timer",
            iconColor: .red
        ),
        NavigationButtonData(
            index: NavigationConstants.journalButtonIndex,
            titleKey: "journal",
            subtitleKey: "homeJournalSubtitle",
            iconName: "book",
            iconColor: .purple
        )
    ]
} 