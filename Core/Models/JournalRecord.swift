//
//  JournalRecord.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import CoreData

public struct JournalRecord {
    public let id = UUID()
    public var date: Date
    public var name: String?
    public var filmName: String?
    public var developerName: String?
    public var iso: Int32?
    public var process: String?
    public var dilution: String?
    public var temperature: Double?
    public var time: Int?
    public var comment: String?
    
    public init(
        date: Date = Date(),
        name: String? = nil,
        filmName: String? = nil,
        developerName: String? = nil,
        iso: Int32? = nil,
        process: String? = nil,
        dilution: String? = nil,
        temperature: Double? = nil,
        time: Int? = nil,
        comment: String? = nil
    ) {
        self.date = date
        self.name = name
        self.filmName = filmName
        self.developerName = developerName
        self.iso = iso
        self.process = process
        self.dilution = dilution
        self.temperature = temperature
        self.time = time
        self.comment = comment
    }
    
    // MARK: - Conversion Methods
    
    public func toCalculationRecord(context: NSManagedObjectContext) -> CalculationRecord {
        let record = CalculationRecord(context: context)
        record.date = date
        record.name = name
        record.filmName = filmName
        record.developerName = developerName
        record.iso = iso ?? 100
        record.process = process
        record.dilution = dilution
        record.temperature = temperature ?? 0.0
        record.time = Int32(time ?? 0)
        record.comment = comment
        return record
    }
    
    public static func fromCalculationRecord(_ record: CalculationRecord) -> JournalRecord {
        return JournalRecord(
            date: record.date ?? Date(),
            name: record.name,
            filmName: record.filmName,
            developerName: record.developerName,
            iso: record.iso,
            process: record.process,
            dilution: record.dilution,
            temperature: record.temperature,
            time: Int(record.time),
            comment: record.comment
        )
    }
} 
