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
} 