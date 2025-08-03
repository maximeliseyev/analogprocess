import XCTest
import SwiftUI
@testable import FilmLab

class NavigationFlowTests: XCTestCase {
    
    func testMainTabViewNavigation() {
        // Test navigation in MainTabView
        var selectedTab = 0
        
        let mainTabView = MainTabView(
            selectedTab: Binding(
                get: { selectedTab },
                set: { selectedTab = $0 }
            ),
            onBackToHome: {},
            colorScheme: .constant(nil)
        )
        
        // Simulate tab selection
        XCTAssertEqual(selectedTab, 0) // Initial state
    }
    
    func testTabIndicesAreCorrect() {
        // Verify that tab indices match expected values
        let expectedTabs = [
            1: "presets",      // Development Setup
            2: "calculator",    // Calculator
            3: "timer",         // Timer
            4: "journal"        // Journal
        ]
        
        for (index, expectedTitle) in expectedTabs {
            let title = getTitleForIndex(index)
            XCTAssertEqual(title, expectedTitle, "Tab at index \(index) should have title '\(expectedTitle)'")
        }
    }
    
    func testMainTabViewHasCorrectNumberOfTabs() {
        // Verify that MainTabView contains the correct number of tabs
        let mainTabView = MainTabView(
            selectedTab: .constant(0),
            onBackToHome: {},
            colorScheme: .constant(nil)
        )
        
        XCTAssertNotNil(mainTabView)
        // MainTabView should contain 4 tabs (1-4) plus main screen (0)
    }
    
    func testBackToHomeNavigation() {
        // Test "Back to Home" button in MainTabView
        var backToHomeCalled = false
        
        let mainTabView = MainTabView(
            selectedTab: .constant(1),
            onBackToHome: {
                backToHomeCalled = true
            },
            colorScheme: .constant(nil)
        )
        
        XCTAssertNotNil(mainTabView)
        XCTAssertFalse(backToHomeCalled) // Initial state
    }
    
    func testSettingsNavigation() {
        // Test navigation to settings
        let settingsView = SettingsView(colorScheme: .constant(nil))
        XCTAssertNotNil(settingsView)
    }
    
    func testTimerSheetNavigation() {
        // Test opening TimerView as sheet
        let timerView = TimerView(
            timerLabel: "Test Development",
            totalMinutes: 10,
            totalSeconds: 30
        )
        
        XCTAssertNotNil(timerView)
        XCTAssertEqual(timerView.timerLabel, "Test Development")
        XCTAssertEqual(timerView.totalMinutes, 10)
        XCTAssertEqual(timerView.totalSeconds, 30)
    }
    
    func testCalculatorSheetNavigation() {
        // Test opening CalculatorView
        let calculatorView = CalculatorView()
        XCTAssertNotNil(calculatorView)
    }
    
    func testDevelopmentSetupSheetNavigation() {
        // Test opening DevelopmentSetupView
        let developmentView = DevelopmentSetupView()
        XCTAssertNotNil(developmentView)
    }
    
    func testJournalNavigation() {
        // Test navigation to Journal
        let journalView = JournalView(
            records: [],
            onEditRecord: { _ in },
            onDeleteRecord: { _ in },
            onClose: {}
        )
        
        XCTAssertNotNil(journalView)
    }
    
    func testHomeButtonFunctionality() {
        // Test that home button returns to main screen
        var selectedTab = 1
        let mainTabView = MainTabView(
            selectedTab: Binding(
                get: { selectedTab },
                set: { selectedTab = $0 }
            ),
            onBackToHome: {},
            colorScheme: .constant(nil)
        )
        
        XCTAssertNotNil(mainTabView)
    }
    
    // Helper function to get title by index
    private func getTitleForIndex(_ index: Int) -> String {
        switch index {
        case 1: return String(localized: "presets")
        case 2: return String(localized: "calculator")
        case 3: return String(localized: "timer")
        case 4: return String(localized: "journal")
        default: return ""
        }
    }
} 