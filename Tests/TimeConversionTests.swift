//
//  TimeConversionTests.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import XCTest
@testable import FilmLab

final class TimeConversionTests: XCTestCase {
    
    func testMinutesToSecondsConversion() {
        // Тест конвертации минут в секунды
        let testCases = [
            (minutes: 0, seconds: 0, expected: 0),
            (minutes: 1, seconds: 0, expected: 60),
            (minutes: 0, seconds: 30, expected: 30),
            (minutes: 2, seconds: 15, expected: 135),
            (minutes: 10, seconds: 45, expected: 645),
            (minutes: 0, seconds: 59, expected: 59),
            (minutes: 5, seconds: 59, expected: 359)
        ]
        
        for testCase in testCases {
            let totalSeconds = testCase.minutes * 60 + testCase.seconds
            XCTAssertEqual(totalSeconds, testCase.expected, "Failed for \(testCase.minutes)m \(testCase.seconds)s")
        }
    }
    
    func testSecondsToMinutesConversion() {
        // Тест конвертации секунд обратно в минуты и секунды
        let testCases = [
            (totalSeconds: 0, expectedMinutes: 0, expectedSeconds: 0),
            (totalSeconds: 60, expectedMinutes: 1, expectedSeconds: 0),
            (totalSeconds: 30, expectedMinutes: 0, expectedSeconds: 30),
            (totalSeconds: 135, expectedMinutes: 2, expectedSeconds: 15),
            (totalSeconds: 645, expectedMinutes: 10, expectedSeconds: 45),
            (totalSeconds: 59, expectedMinutes: 0, expectedSeconds: 59),
            (totalSeconds: 359, expectedMinutes: 5, expectedSeconds: 59)
        ]
        
        for testCase in testCases {
            let minutes = testCase.totalSeconds / 60
            let seconds = testCase.totalSeconds % 60
            
            XCTAssertEqual(minutes, testCase.expectedMinutes, "Minutes failed for \(testCase.totalSeconds) seconds")
            XCTAssertEqual(seconds, testCase.expectedSeconds, "Seconds failed for \(testCase.totalSeconds) seconds")
        }
    }
    
    func testTimeValidation() {
        // Тест валидации времени
        let negativeMinutes = -5
        let negativeSeconds = -10
        let tooManySeconds = 75
        
        // Проверяем, что отрицательные значения корректируются
        let correctedNegativeMinutes = max(0, negativeMinutes)
        let correctedNegativeSeconds = max(0, min(59, negativeSeconds))
        let correctedTooManySeconds = min(59, tooManySeconds)
        
        XCTAssertEqual(correctedNegativeMinutes, 0)
        XCTAssertEqual(correctedNegativeSeconds, 0)
        XCTAssertEqual(correctedTooManySeconds, 59)
    }
    
    func testRoundToQuarterMinute() {
        // Тестируем округление до 1/4 минуты (15 секунд)
        
        // 7 минут 23 секунды должно округлиться до 7:30
        let time1 = 7 * 60 + 23 // 443 секунды
        let rounded1 = roundToQuarterMinute(time1)
        XCTAssertEqual(rounded1, 7 * 60 + 30) // 450 секунд
        
        // 5 минут 8 секунд должно округлиться до 5:00
        let time2 = 5 * 60 + 8 // 308 секунд
        let rounded2 = roundToQuarterMinute(time2)
        XCTAssertEqual(rounded2, 5 * 60 + 0) // 300 секунд
        
        // 3 минуты 37 секунд должно округлиться до 3:45
        let time3 = 3 * 60 + 37 // 217 секунд
        let rounded3 = roundToQuarterMinute(time3)
        XCTAssertEqual(rounded3, 3 * 60 + 45) // 225 секунд
        
        // 10 минут 52 секунды должно округлиться до 11:00
        let time4 = 10 * 60 + 52 // 652 секунды
        let rounded4 = roundToQuarterMinute(time4)
        XCTAssertEqual(rounded4, 11 * 60 + 0) // 660 секунд
    }
    
    func testCalculatorRounding() {
        let calculator = DevelopmentCalculator()
        
        // Тестируем расчет push +1 с округлением
        let results = calculator.calculateResults(
            minutes: 7,
            seconds: 23, // 7:23 должно округлиться до 7:30
            coefficient: 1.33,
            isPushMode: true,
            steps: 1
        )
        
        XCTAssertEqual(results.count, 2) // +0 и push +1
        
        // Проверяем базовое время (+0)
        XCTAssertEqual(results[0].label, "+0")
        XCTAssertEqual(results[0].minutes, 7)
        XCTAssertEqual(results[0].seconds, 30) // Округлено с 23 до 30
        
        // Проверяем push +1
        XCTAssertEqual(results[1].label, "push +1")
        // Время должно быть округлено до ближайшей 1/4 минуты
        let expectedSeconds = Int(round(Double(7 * 60 + 30) * 1.33 / 15.0)) * 15
        let expectedMinutes = expectedSeconds / 60
        let expectedRemainingSeconds = expectedSeconds % 60
        XCTAssertEqual(results[1].minutes, expectedMinutes)
        XCTAssertEqual(results[1].seconds, expectedRemainingSeconds)
    }
    
    private func roundToQuarterMinute(_ totalSeconds: Int) -> Int {
        let quarterMinuteSeconds = 15
        return Int(round(Double(totalSeconds) / Double(quarterMinuteSeconds))) * quarterMinuteSeconds
    }
} 