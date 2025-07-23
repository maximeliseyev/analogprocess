//
//  TestORWOScheme.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// Тестовый файл для проверки схемы ORWO
struct TestORWOScheme {
    static func testORWOScheme() {
        print("=== Тестирование схемы ORWO ===")
        
        // Находим режим ORWO
        guard let orwoMode = AgitationMode.presets.first(where: { $0.name == "ORWO" }) else {
            print("Режим ORWO не найден!")
            return
        }
        
        // Тестируем для разных длительностей проявки
        let testDurations = [3, 5, 8, 10]
        
        for totalMinutes in testDurations {
            print("\n--- Проявка \(totalMinutes) минут ---")
            
            for minute in 1...totalMinutes {
                if let agitationType = orwoMode.getAgitationForMinute(minute, totalMinutes: totalMinutes) {
                    let description = getAgitationDescription(agitationType)
                    print("Минута \(minute): \(description)")
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
// TestORWOScheme.testORWOScheme() 