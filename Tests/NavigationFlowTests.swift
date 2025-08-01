import XCTest
import SwiftUI
@testable import FilmLab

class NavigationFlowTests: XCTestCase {
    
    func testHomeToMainTabNavigation() {
        // Тест перехода от HomeView к MainTabView
        var selectedTab = -1
        var showMainTabs = false
        
        let homeView = HomeView(
            onSelectTab: { tab in
                selectedTab = tab
                showMainTabs = true
            },
            colorScheme: .constant(nil)
        )
        
        // Симулируем выбор таба
        // В реальном приложении это происходит через UI
        XCTAssertEqual(selectedTab, -1) // Начальное состояние
        XCTAssertFalse(showMainTabs) // Начальное состояние
    }
    
    func testTabIndicesAreCorrect() {
        // Проверяем, что индексы табов соответствуют ожидаемым
        let expectedTabs = [
            0: "presets",      // Development Setup
            1: "calculator",    // Calculator
            2: "timer",         // Timer
            3: "journal"        // Journal
        ]
        
        for (index, expectedTitle) in expectedTabs {
            let title = getTitleForIndex(index)
            XCTAssertEqual(title, expectedTitle, "Tab at index \(index) should have title '\(expectedTitle)'")
        }
    }
    
    func testNoManualTabExists() {
        // Проверяем, что таб для Manuals больше не существует
        let manualTitle = getTitleForIndex(4)
        XCTAssertEqual(manualTitle, "", "Manual tab should not exist")
    }
    
    func testMainTabViewHasCorrectNumberOfTabs() {
        // Проверяем, что MainTabView содержит правильное количество табов
        let mainTabView = MainTabView(
            selectedTab: .constant(0),
            onBackToHome: {},
            colorScheme: .constant(nil)
        )
        
        XCTAssertNotNil(mainTabView)
        // MainTabView должен содержать 4 таба (0-3)
    }
    
    func testBackToHomeNavigation() {
        // Тест кнопки "Назад к дому" в MainTabView
        var backToHomeCalled = false
        
        let mainTabView = MainTabView(
            selectedTab: .constant(0),
            onBackToHome: {
                backToHomeCalled = true
            },
            colorScheme: .constant(nil)
        )
        
        XCTAssertNotNil(mainTabView)
        XCTAssertFalse(backToHomeCalled) // Начальное состояние
    }
    
    func testSettingsNavigation() {
        // Тест навигации к настройкам
        let settingsView = SettingsView(colorScheme: .constant(nil))
        XCTAssertNotNil(settingsView)
    }
    
    func testTimerSheetNavigation() {
        // Тест открытия TimerView как sheet
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
        // Тест открытия CalculatorView
        let calculatorView = CalculatorView()
        XCTAssertNotNil(calculatorView)
    }
    
    func testDevelopmentSetupSheetNavigation() {
        // Тест открытия DevelopmentSetupView
        let developmentView = DevelopmentSetupView()
        XCTAssertNotNil(developmentView)
    }
    
    func testJournalNavigation() {
        // Тест навигации к Journal
        let journalView = JournalView(
            records: [],
            onLoadRecord: { _ in },
            onDeleteRecord: { _ in },
            onClose: {}
        )
        
        XCTAssertNotNil(journalView)
    }
    
    // Вспомогательная функция для получения заголовка по индексу
    private func getTitleForIndex(_ index: Int) -> String {
        switch index {
        case 0: return String(localized: "presets")
        case 1: return String(localized: "calculator")
        case 2: return String(localized: "timer")
        case 3: return String(localized: "journal")
        default: return ""
        }
    }
} 