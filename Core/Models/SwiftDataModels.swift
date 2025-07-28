//
//  SwiftDataModels.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 25.07.2025.
//

import SwiftData
import Foundation

// MARK: - Models

@Model
public class FilmManufacturer {
    @Attribute(.unique) public var id: String
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

@Model
public class Film {
    @Attribute(.unique) public var id: String
    public var name: String
    public var manufacturer: String
    public var type: String
    public var defaultISO: Int
    
    @Relationship(deleteRule: .cascade) public var developmentTimes: [DevelopmentTime] = []
    
    public init(id: String, name: String, manufacturer: String, type: String, defaultISO: Int) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.type = type
        self.defaultISO = defaultISO
    }
}

@Model
public class Developer {
    @Attribute(.unique) public var id: String
    public var name: String
    public var manufacturer: String
    public var defaultDilution: String
    
    @Relationship(deleteRule: .cascade) public var developmentTimes: [DevelopmentTime] = []
    
    public init(id: String, name: String, manufacturer: String, defaultDilution: String) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.defaultDilution = defaultDilution
    }
}

@Model
public class DevelopmentTime {
    @Attribute(.unique) public var id: String
    public var filmId: String
    public var developerId: String
    public var dilution: String
    public var iso: Int
    public var timeInSeconds: Int
    
    // Связи
    @Relationship(inverse: \Film.developmentTimes) public var film: Film?
    @Relationship(inverse: \Developer.developmentTimes) public var developer: Developer?
    
    public init(filmId: String, developerId: String, dilution: String, iso: Int, timeInSeconds: Int) {
        self.id = "\(filmId)-\(developerId)-\(dilution)-\(iso)"
        self.filmId = filmId
        self.developerId = developerId
        self.dilution = dilution
        self.iso = iso
        self.timeInSeconds = timeInSeconds
    }
}

@Model
public class TemperatureMultiplier {
    @Attribute(.unique) public var temperature: Int
    public var multiplier: Double
    
    public init(temperature: Int, multiplier: Double) {
        self.temperature = temperature
        self.multiplier = multiplier
    }
}

@Model
public class CalculationRecord {
    @Attribute(.unique) public var id: String
    public var filmName: String
    public var developerName: String
    public var dilution: String
    public var iso: Int
    public var time: Int
    public var temperature: Double
    public var date: Date
    public var notes: String?
    
    public init(filmName: String, developerName: String, dilution: String, iso: Int, time: Int, temperature: Double, notes: String? = nil) {
        self.id = UUID().uuidString
        self.filmName = filmName
        self.developerName = developerName
        self.dilution = dilution
        self.iso = iso
        self.time = time
        self.temperature = temperature
        self.date = Date()
        self.notes = notes
    }
}

// MARK: - Helper Extensions

extension DevelopmentTime {
    /// Возвращает время в минутах и секундах
    public var formattedTime: String {
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Вычисляет время с учетом температуры
    public func adjustedTime(for temperature: Int, context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<TemperatureMultiplier>(
            predicate: #Predicate { $0.temperature == temperature }
        )
        
        guard let multiplier = try? context.fetch(descriptor).first else {
            return timeInSeconds // Возвращаем базовое время, если множитель не найден
        }
        
        return Int(Double(timeInSeconds) * multiplier.multiplier)
    }
} 