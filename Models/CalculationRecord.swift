//
//  CalculationRecord.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import Foundation


struct CalculationRecord {
    let id = UUID()
    let name: String
    let date: Date
    let minutes: Int
    let seconds: Int
    let coefficient: Double
    let isPushMode: Bool
    let pushSteps: Int
}
