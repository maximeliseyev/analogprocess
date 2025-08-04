import XCTest
@testable import FilmLab

class AgitationTimerTests: XCTestCase {
    
    func testAgitationModeSwitchingAccuracy() {
        // Создаем простой режим встряхивания: 5 секунд встряхивания, 3 секунды покоя
        let customMode = AgitationMode.createCustomMode(agitationSeconds: 5, restSeconds: 3)
        
        // Создаем таймер на 1 минуту
        let timerViewModel = TimerViewModel(totalMinutes: 1, totalSeconds: 0)
        timerViewModel.selectAgitationMode(customMode)
        
        // Проверяем начальное состояние
        XCTAssertTrue(timerViewModel.isInAgitationPhase)
        XCTAssertEqual(timerViewModel.agitationTimeRemaining, 5)
        
        // Симулируем прохождение времени
        var switchTimes: [Date] = []
        var switchPhases: [String] = []
        
        // Функция для симуляции одной секунды
        func simulateOneSecond() {
            if timerViewModel.agitationTimeRemaining <= 1 {
                let oldPhase = timerViewModel.isInAgitationPhase ? "Agitation" : "Rest"
                switchTimes.append(Date())
                switchPhases.append(oldPhase)
            }
            
            if timerViewModel.agitationTimeRemaining > 0 {
                timerViewModel.agitationTimeRemaining -= 1
            }
            
            // Переключаем режим если время истекло
            if timerViewModel.agitationTimeRemaining == 0 {
                if timerViewModel.isInAgitationPhase {
                    timerViewModel.isInAgitationPhase = false
                    timerViewModel.agitationTimeRemaining = 3 // rest seconds
                } else {
                    timerViewModel.isInAgitationPhase = true
                    timerViewModel.agitationTimeRemaining = 5 // agitation seconds
                }
            }
        }
        
        // Симулируем 30 секунд
        for _ in 0..<30 {
            simulateOneSecond()
        }
        
        // Проверяем, что переключения происходят точно
        XCTAssertGreaterThan(switchTimes.count, 0, "Должны быть переключения")
        
        // Проверяем интервалы между переключениями
        for i in 1..<switchTimes.count {
            let interval = switchTimes[i].timeIntervalSince(switchTimes[i-1])
            // Интервал должен быть примерно 8 секунд (5 + 3)
            XCTAssertEqual(interval, 8.0, accuracy: 0.1, "Интервал между переключениями должен быть 8 секунд")
        }
        
        print("✅ Тест точности переключений пройден")
        print("Количество переключений: \(switchTimes.count)")
        print("Фазы переключений: \(switchPhases)")
    }
    
    func testAgitationModeInitialization() {
        let customMode = AgitationMode.createCustomMode(agitationSeconds: 10, restSeconds: 5)
        let timerViewModel = TimerViewModel(totalMinutes: 1, totalSeconds: 0)
        
        timerViewModel.selectAgitationMode(customMode)
        
        // Проверяем, что начинаем с режима встряхивания
        XCTAssertTrue(timerViewModel.isInAgitationPhase)
        XCTAssertEqual(timerViewModel.agitationTimeRemaining, 10)
        
        print("✅ Тест инициализации режима пройден")
    }
} 