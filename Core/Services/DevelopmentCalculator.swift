//
//  DevelopmentCalculator.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI
import CoreData

class DevelopmentCalculator {
    private let coreDataService = CoreDataService.shared
    
    /// Округляет время до ближайшей 1/4 минуты (15 секунд)
    private func roundToQuarterMinute(_ totalSeconds: Int) -> (minutes: Int, seconds: Int) {
        let quarterMinuteSeconds = 15
        let roundedSeconds = Int(round(Double(totalSeconds) / Double(quarterMinuteSeconds))) * quarterMinuteSeconds
        
        let minutes = roundedSeconds / 60
        let seconds = roundedSeconds % 60
        
        return (minutes: minutes, seconds: seconds)
    }
    
    func calculateResults(
        minutes: Int,
        seconds: Int,
        coefficient: Double,
        temperature: Double,
        isPushMode: Bool,
        steps: Int
    ) -> [(label: String, minutes: Int, seconds: Int)] {
        
        let baseSeconds = minutes * 60 + seconds
        
        // Применяем температурный коэффициент к базовому времени
        let temperatureMultiplier = coreDataService.getTemperatureMultiplier(for: temperature)
        let adjustedBaseSeconds = Int(Double(baseSeconds) * temperatureMultiplier)
        
        print("DEBUG: Calculator - Base time: \(baseSeconds)s, Temperature: \(temperature)°C, Multiplier: \(temperatureMultiplier), Adjusted time: \(adjustedBaseSeconds)s")
        
        var results: [(label: String, minutes: Int, seconds: Int)] = []
        
        // Базовое время (+0) - округляем
        let baseRounded = roundToQuarterMinute(adjustedBaseSeconds)
        results.append((
            label: "+0",
            minutes: baseRounded.minutes,
            seconds: baseRounded.seconds
        ))
        
        if isPushMode {
            results.append(contentsOf: calculatePushProcess(baseSeconds: adjustedBaseSeconds, coefficient: coefficient, steps: steps))
        } else {
            results.append(contentsOf: calculatePullProcess(baseSeconds: adjustedBaseSeconds, coefficient: coefficient, steps: steps))
        }
        
        return results
    }
    
    private func calculatePushProcess(baseSeconds: Int, coefficient: Double, steps: Int) -> [(label: String, minutes: Int, seconds: Int)] {
        var results: [(label: String, minutes: Int, seconds: Int)] = []
        
        for i in 1...steps {
            let multiplier = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) * multiplier)
            
            // Округляем результат до 1/4 минуты
            let rounded = roundToQuarterMinute(adjustedSeconds)
            
            results.append((
                label: "push +\(i)",
                minutes: rounded.minutes,
                seconds: rounded.seconds
            ))
        }
        
        return results
    }
    
    private func calculatePullProcess(baseSeconds: Int, coefficient: Double, steps: Int) -> [(label: String, minutes: Int, seconds: Int)] {
        var results: [(label: String, minutes: Int, seconds: Int)] = []
        
        for i in 1...steps {
            let divisor = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) / divisor)
            
            // Округляем результат до 1/4 минуты
            let rounded = roundToQuarterMinute(adjustedSeconds)
            
            results.append((
                label: "pull -\(i)",
                minutes: rounded.minutes,
                seconds: rounded.seconds
            ))
        }
        
        return results
    }
}
