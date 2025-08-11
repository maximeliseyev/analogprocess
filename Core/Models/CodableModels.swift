//
//  CodableModels.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// MARK: - Film Model
public struct FilmData: Codable, Identifiable {
    public let id: String
    public let name: String
    public let brand: String
    public let iso: Int
    public let type: String
    public let description: String?
    
    public init(id: String, name: String, brand: String, iso: Int, type: String, description: String? = nil) {
        self.id = id
        self.name = name
        self.brand = brand
        self.iso = iso
        self.type = type
        self.description = description
    }
}

// MARK: - Developer Model
public struct DeveloperData: Codable, Identifiable {
    public let id: String
    public let name: String
    public let brand: String
    public let type: String
    public let description: String?
    public let dilution: String?
    
    public init(id: String, name: String, brand: String, type: String, description: String? = nil, dilution: String? = nil) {
        self.id = id
        self.name = name
        self.brand = brand
        self.type = type
        self.description = description
        self.dilution = dilution
    }
}

// MARK: - Development Time Model
public struct DevelopmentTimeData: Codable {
    public let filmId: String
    public let developerId: String
    public let iso: Int
    public let temperature: Int
    public let timeMinutes: Int
    public let timeSeconds: Int
    
    public init(filmId: String, developerId: String, iso: Int, temperature: Int, timeMinutes: Int, timeSeconds: Int) {
        self.filmId = filmId
        self.developerId = developerId
        self.iso = iso
        self.temperature = temperature
        self.timeMinutes = timeMinutes
        self.timeSeconds = timeSeconds
    }
}

// MARK: - Temperature Multiplier Model
public struct TemperatureMultiplierData: Codable {
    public let temperature: Int
    public let multiplier: Double
    
    public init(temperature: Int, multiplier: Double) {
        self.temperature = temperature
        self.multiplier = multiplier
    }
}

// MARK: - Process Step Model
public struct ProcessStep: Codable, Identifiable {
    public let id: UUID
    public let label: String
    public let minutes: Int
    public let seconds: Int
    
    public init(label: String, minutes: Int, seconds: Int) {
        self.id = UUID()
        self.label = label
        self.minutes = minutes
        self.seconds = seconds
    }
    
    public var totalSeconds: Int {
        return minutes * 60 + seconds
    }
    
    public var formattedTime: String {
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - GitHub Data Response Models
public struct GitHubDataResponse: Codable {
    public let films: [String: FilmData]
    public let developers: [String: DeveloperData]
    public let developmentTimes: [String: [String: [String: [String: Int]]]]
    public let temperatureMultipliers: [String: Double]
    
    public init(films: [String: FilmData], developers: [String: DeveloperData], developmentTimes: [String: [String: [String: [String: Int]]]], temperatureMultipliers: [String: Double]) {
        self.films = films
        self.developers = developers
        self.developmentTimes = developmentTimes
        self.temperatureMultipliers = temperatureMultipliers
    }
}
