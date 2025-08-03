//
//  JournalIntegrationTests.swift
//  FilmLab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import XCTest
@testable import FilmLab

final class JournalIntegrationTests: XCTestCase {
    
    var coreDataService: CoreDataService!
    
    override func setUp() {
        super.setUp()
        coreDataService = CoreDataService.shared
    }
    
    override func tearDown() {
        // Очищаем тестовые данные
        coreDataService.clearAllData()
        super.tearDown()
    }
    
    func testCreateJournalRecord() {
        // Тест создания записи журнала
        let journalRecord = JournalRecord(
            date: Date(),
            name: "Test Record",
            filmName: "Test Film",
            developerName: "Test Developer",
            dilution: "1+1",
            temperature: 20.0,
            time: 300,
            comment: "Test comment"
        )
        
        coreDataService.saveJournalRecord(journalRecord)
        
        let records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 1, "Should have one record")
        
        let record = records.first!
        XCTAssertEqual(record.name, "Test Record")
        XCTAssertEqual(record.filmName, "Test Film")
        XCTAssertEqual(record.developerName, "Test Developer")
        XCTAssertEqual(record.dilution, "1+1")
        XCTAssertEqual(record.temperature, 20.0)
        XCTAssertEqual(record.time, 300)
        XCTAssertEqual(record.comment, "Test comment")
    }
    
    func testJournalRecordConversion() {
        // Тест конвертации между JournalRecord и CalculationRecord
        let originalRecord = JournalRecord(
            date: Date(),
            name: "Conversion Test",
            filmName: "Test Film",
            developerName: "Test Developer",
            dilution: "1+2",
            temperature: 22.0,
            time: 450,
            comment: "Conversion test"
        )
        
        // Конвертируем в CalculationRecord
        let calculationRecord = originalRecord.toCalculationRecord(context: coreDataService.container.viewContext)
        
        // Конвертируем обратно в JournalRecord
        let convertedRecord = JournalRecord.fromCalculationRecord(calculationRecord)
        
        // Проверяем, что данные сохранились
        XCTAssertEqual(convertedRecord.name, originalRecord.name)
        XCTAssertEqual(convertedRecord.filmName, originalRecord.filmName)
        XCTAssertEqual(convertedRecord.developerName, originalRecord.developerName)
        XCTAssertEqual(convertedRecord.dilution, originalRecord.dilution)
        XCTAssertEqual(convertedRecord.temperature, originalRecord.temperature)
        XCTAssertEqual(convertedRecord.time, originalRecord.time)
        XCTAssertEqual(convertedRecord.comment, originalRecord.comment)
    }
    
    func testJournalRecordValidation() {
        // Тест валидации записей журнала
        let validRecord = JournalRecord(
            filmName: "Valid Film",
            developerName: "Valid Developer"
        )
        
        let invalidRecord = JournalRecord(
            filmName: "",
            developerName: ""
        )
        
        // Проверяем, что валидная запись может быть сохранена
        XCTAssertNoThrow(coreDataService.saveJournalRecord(validRecord))
        
        // Проверяем, что невалидная запись также может быть сохранена (так как валидация происходит в UI)
        XCTAssertNoThrow(coreDataService.saveJournalRecord(invalidRecord))
    }
    
    func testJournalRecordOptionalFields() {
        // Тест опциональных полей
        let minimalRecord = JournalRecord(
            filmName: "Minimal Film",
            developerName: "Minimal Developer"
        )
        
        coreDataService.saveJournalRecord(minimalRecord)
        
        let records = coreDataService.getCalculationRecords()
        let record = records.first!
        
        XCTAssertNil(record.name)
        XCTAssertNil(record.comment)
        XCTAssertEqual(record.filmName, "Minimal Film")
        XCTAssertEqual(record.developerName, "Minimal Developer")
    }
} 