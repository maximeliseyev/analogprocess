//
//  SwiftDataModels.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData

// MARK: - SwiftData Film Model
@Model
public final class SwiftDataFilm {
    @Attribute(.unique) public var id: String
    public var name: String
    public var manufacturer: String
    public var type: String
    public var defaultISO: Int32
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \SwiftDataDevelopmentTime.film)
    public var developmentTimes: [SwiftDataDevelopmentTime] = []
    
    public init(id: String, name: String, manufacturer: String, type: String, defaultISO: Int32) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.type = type
        self.defaultISO = defaultISO
    }
}

// MARK: - SwiftData Developer Model
@Model
public final class SwiftDataDeveloper {
    @Attribute(.unique) public var id: String
    public var name: String
    public var manufacturer: String
    public var type: String
    public var defaultDilution: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \SwiftDataDevelopmentTime.developer)
    public var developmentTimes: [SwiftDataDevelopmentTime] = []
    
    public init(id: String, name: String, manufacturer: String, type: String, defaultDilution: String? = nil) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.type = type
        self.defaultDilution = defaultDilution
    }
}

// MARK: - SwiftData DevelopmentTime Model
@Model
public final class SwiftDataDevelopmentTime {
    public var dilution: String?
    public var iso: Int32
    public var time: Int32
    
    // Relationships
    public var developer: SwiftDataDeveloper?
    public var film: SwiftDataFilm?
    
    public init(dilution: String?, iso: Int32, time: Int32, developer: SwiftDataDeveloper? = nil, film: SwiftDataFilm? = nil) {
        self.dilution = dilution
        self.iso = iso
        self.time = time
        self.developer = developer
        self.film = film
    }
}

// MARK: - SwiftData Fixer Model
@Model
public final class SwiftDataFixer {
    @Attribute(.unique) public var id: String
    public var name: String
    public var type: String
    public var time: Int32
    public var warning: String?
    
    public init(id: String, name: String, type: String, time: Int32, warning: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.time = time
        self.warning = warning
    }
}

// MARK: - SwiftData TemperatureMultiplier Model
@Model
public final class SwiftDataTemperatureMultiplier {
    public var temperature: Int32
    public var multiplier: Double
    
    public init(temperature: Int32, multiplier: Double) {
        self.temperature = temperature
        self.multiplier = multiplier
    }
}

// MARK: - SwiftData CalculationRecord Model
@Model
public final class SwiftDataCalculationRecord {
    public var comment: String?
    public var date: Date?
    public var developerName: String?
    public var dilution: String?
    public var filmName: String?
    public var iso: Int32
    public var isSynced: Bool
    public var lastModified: Date?
    public var name: String?
    public var process: String?
    public var recordID: String?
    public var temperature: Double
    public var time: Int32
    
    public init(
        comment: String? = nil,
        date: Date? = nil,
        developerName: String? = nil,
        dilution: String? = nil,
        filmName: String? = nil,
        iso: Int32 = 0,
        isSynced: Bool = false,
        lastModified: Date? = nil,
        name: String? = nil,
        process: String? = nil,
        recordID: String? = nil,
        temperature: Double = 0.0,
        time: Int32 = 0
    ) {
        self.comment = comment
        self.date = date
        self.developerName = developerName
        self.dilution = dilution
        self.filmName = filmName
        self.iso = iso
        self.isSynced = isSynced
        self.lastModified = lastModified
        self.name = name
        self.process = process
        self.recordID = recordID
        self.temperature = temperature
        self.time = time
    }
}
