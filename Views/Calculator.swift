//
//  Calculator.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//


func calculateDevelopmentTime(minutes: Int, seconds: Int, coefficient: Double) -> (minutes: Int, seconds: Int) {
    let totalSeconds = minutes * 60 + seconds
    let adjustedSeconds = Int(Double(totalSeconds) * coefficient)
    
    let resultMinutes = adjustedSeconds / 60
    let resultSeconds = adjustedSeconds % 60
    
    return (resultMinutes, resultSeconds)
}