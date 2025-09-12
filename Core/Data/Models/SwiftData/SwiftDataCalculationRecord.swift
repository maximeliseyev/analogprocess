//
//  SwiftDataCalculationRecord.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import Foundation
import SwiftData

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
    public var temperature: Int
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
        temperature: Int = 20,
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