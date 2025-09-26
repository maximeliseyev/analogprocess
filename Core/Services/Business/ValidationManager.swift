//
//  ValidationManager.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 25.09.2025.
//

import Foundation

enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidInteger(String)
    case invalidDouble(String)
    case valueOutOfRange(String, ClosedRange<Int>)

    var errorDescription: String? {
        switch self {
        case .emptyField(let fieldName):
            return "\(fieldName) cannot be empty."
        case .invalidInteger(let fieldName):
            return "\(fieldName) must be a valid integer."
        case .invalidDouble(let fieldName):
            return "\(fieldName) must be a valid number."
        case .valueOutOfRange(let fieldName, let range):
            return "\(fieldName) must be between \(range.lowerBound) and \(range.upperBound)."
        }
    }
}

protocol Validator {
    func validate() -> [ValidationError]
}

struct ValidationManager {

    static func validate(validators: [Validator]) -> [ValidationError] {
        return validators.flatMap { $0.validate() }
    }
    
    static func validateNotEmpty(field: String, fieldName: String) -> [ValidationError] {
        if field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return [.emptyField(fieldName)]
        }
        return []
    }
    
    static func validateInt(field: String, fieldName: String, range: ClosedRange<Int>? = nil) -> [ValidationError] {
        guard let intValue = Int(field) else {
            return [.invalidInteger(fieldName)]
        }
        if let range = range, !range.contains(intValue) {
            return [.valueOutOfRange(fieldName, range)]
        }
        return []
    }

    static func validateDouble(field: String, fieldName: String, greaterThanZero: Bool = false) -> [ValidationError] {
        guard let doubleValue = Double(field) else {
            return [.invalidDouble(fieldName)]
        }
        if greaterThanZero && doubleValue <= 0 {
            // A more specific error could be created for this case
            return [.invalidDouble("\(fieldName) must be greater than 0")]
        }
        return []
    }
}
