//
//  DevelopmentCalculator.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import SwiftUI

class DevelopmentCalculator {
    func calculateResults(
        minutes: Int,
        seconds: Int,
        coefficient: Double,
        isPushMode: Bool,
        steps: Int
    ) -> [(label: String, minutes: Int, seconds: Int)] {
        
        let baseSeconds = minutes * 60 + seconds
        var results: [(label: String, minutes: Int, seconds: Int)] = []
        
        // Базовое время (+0)
        results.append((
            label: "+0",
            minutes: minutes,
            seconds: seconds
        ))
        
        if isPushMode {
            results.append(contentsOf: calculatePushProcess(baseSeconds: baseSeconds, coefficient: coefficient, steps: steps))
        } else {
            results.append(contentsOf: calculatePullProcess(baseSeconds: baseSeconds, coefficient: coefficient, steps: steps))
        }
        
        return results
    }
    
    private func calculatePushProcess(baseSeconds: Int, coefficient: Double, steps: Int) -> [(label: String, minutes: Int, seconds: Int)] {
        var results: [(label: String, minutes: Int, seconds: Int)] = []
        
        for i in 1...steps {
            let multiplier = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) * multiplier)
            
            let resultMinutes = adjustedSeconds / 60
            let resultSeconds = adjustedSeconds % 60
            
            results.append((
                label: "push +\(i)",
                minutes: resultMinutes,
                seconds: resultSeconds
            ))
        }
        
        return results
    }
    
    private func calculatePullProcess(baseSeconds: Int, coefficient: Double, steps: Int) -> [(label: String, minutes: Int, seconds: Int)] {
        var results: [(label: String, minutes: Int, seconds: Int)] = []
        
        for i in 1...steps {
            let divisor = pow(coefficient, Double(i))
            let adjustedSeconds = Int(Double(baseSeconds) / divisor)
            
            let resultMinutes = adjustedSeconds / 60
            let resultSeconds = adjustedSeconds % 60
            
            results.append((
                label: "pull -\(i)",
                minutes: resultMinutes,
                seconds: resultSeconds
            ))
        }
        
        return results
    }
}
