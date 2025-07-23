//
//  TestAgitationModes.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// Тестовый файл для проверки новых режимов ажитации
struct TestAgitationModes {
    static func testAgitationModes() {
        print("=== Тестирование режимов ажитации ===")
        
        for mode in AgitationMode.presets {
            print("\n--- \(mode.name) ---")
            print("Описание: \(mode.description)")
            
            // Тестируем для первых 5 минут
            for minute in 1...5 {
                if let agitationType = mode.getAgitationForMinute(minute) {
                    print("Минута \(minute): \(getAgitationDescription(agitationType))")
                } else {
                    print("Минута \(minute): режим не определен")
                }
            }
        }
    }
    
    private static func getAgitationDescription(_ type: AgitationMode.PhaseAgitationType) -> String {
        switch type {
        case .continuous:
            return "Непрерывная ажитация"
        case .cycle(let agitation, let rest):
            return "\(agitation)с ажитации / \(rest)с покоя"
        case .periodic(let interval):
            return "Каждые \(interval)с"
        case .custom(let description):
            return description
        }
    }
}

// Пример использования:
// TestAgitationModes.testAgitationModes() 