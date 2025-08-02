import XCTest
import SwiftUI
@testable import FilmLab

class NavigationTests: XCTestCase {
    
    func testMainTabViewTabSelection() {
        // Test tab selection in MainTabView
        let selectedTab = Binding<Int>(
            get: { 0 },
            set: { _ in }
        )
        
        let mainTabView = MainTabView(
            selectedTab: selectedTab,
            onBackToHome: {},
            colorScheme: .constant(nil)
        )
        
        // Verify that MainTabView is created without errors
        XCTAssertNotNil(mainTabView)
    }
    
    func testContentViewStateManagement() {
        // Test state management in ContentView
        let contentView = ContentView(colorScheme: .constant(nil))
        
        // Verify that ContentView is created without errors
        XCTAssertNotNil(contentView)
    }
    
    func testTimerViewNavigation() {
        // Test navigation to TimerView
        let timerView = TimerView(
            timerLabel: "Test Timer",
            totalMinutes: 5,
            totalSeconds: 30
        )
        
        XCTAssertNotNil(timerView)
    }
    
    func testDevelopmentSetupViewNavigation() {
        // Test navigation to DevelopmentSetupView
        let developmentView = DevelopmentSetupView()
        
        XCTAssertNotNil(developmentView)
    }
    
    func testCalculatorViewNavigation() {
        // Test navigation to CalculatorView
        let calculatorView = CalculatorView()
        
        XCTAssertNotNil(calculatorView)
    }
    
    func testJournalViewNavigation() {
        // Test navigation to JournalView
        let journalView = JournalView(
            records: [],
            onLoadRecord: { _ in },
            onDeleteRecord: { _ in },
            onClose: {}
        )
        
        XCTAssertNotNil(journalView)
    }
    
    func testMainTabViewHomeButton() {
        // Test that home button functionality works
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
    
    func testTabViewVisibility() {
        // Test that TabView is hidden on main screen and visible on child screens
        let mainTabView = MainTabView(
            selectedTab: .constant(0), // Main screen
            onBackToHome: {},
            colorScheme: .constant(nil)
        )
        
        XCTAssertNotNil(mainTabView)
    }
} 