//
//  CoreDataServiceTests.swift
//  FilmLab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import XCTest
@testable import FilmLab

final class CoreDataServiceTests: XCTestCase {
    
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
    
    func testSaveJournalRecord() {
        // Тест сохранения записи журнала
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
        
        // Проверяем, что метод не вызывает ошибок
        XCTAssertNoThrow(coreDataService.saveJournalRecord(journalRecord))
        
        // Проверяем, что запись была сохранена
        let records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 1, "Should have one record after saving")
        
        let savedRecord = records.first!
        XCTAssertEqual(savedRecord.name, "Test Record")
        XCTAssertEqual(savedRecord.filmName, "Test Film")
        XCTAssertEqual(savedRecord.developerName, "Test Developer")
    }
    
    func testSaveCalculationRecord() {
        // Тест сохранения записи расчета
        XCTAssertNoThrow(coreDataService.saveCalculationRecord(
            filmName: "Test Film",
            developerName: "Test Developer",
            dilution: "1+1",
            iso: 400,
            temperature: 20.0,
            time: 300,
            name: "Test Calculation",
            comment: "Test calculation comment"
        ))
        
        let records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 1, "Should have one record after saving")
        
        let savedRecord = records.first!
        XCTAssertEqual(savedRecord.filmName, "Test Film")
        XCTAssertEqual(savedRecord.developerName, "Test Developer")
        XCTAssertEqual(savedRecord.name, "Test Calculation")
        XCTAssertEqual(savedRecord.comment, "Test calculation comment")
    }
    
    func testDeleteCalculationRecord() {
        // Создаем запись
        let journalRecord = JournalRecord(
            filmName: "Test Film",
            developerName: "Test Developer"
        )
        coreDataService.saveJournalRecord(journalRecord)
        
        // Проверяем, что запись создана
        var records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 1, "Should have one record before deletion")
        
        // Удаляем запись
        let recordToDelete = records.first!
        XCTAssertNoThrow(coreDataService.deleteCalculationRecord(recordToDelete))
        
        // Проверяем, что запись удалена
        records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 0, "Should have no records after deletion")
    }
    
    func testGetCalculationRecords() {
        // Создаем несколько записей
        let record1 = JournalRecord(
            filmName: "Film 1",
            developerName: "Developer 1"
        )
        let record2 = JournalRecord(
            filmName: "Film 2",
            developerName: "Developer 2"
        )
        
        coreDataService.saveJournalRecord(record1)
        coreDataService.saveJournalRecord(record2)
        
        // Проверяем, что все записи получены
        let records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 2, "Should have two records")
        
        // Проверяем сортировку по дате (новые записи должны быть первыми)
        XCTAssertEqual(records[0].filmName, "Film 2")
        XCTAssertEqual(records[1].filmName, "Film 1")
    }
    
    func testSaveContext() {
        // Тест, что saveContext работает без ошибок
        XCTAssertNoThrow(coreDataService.saveContext())
    }
    
    func testClearAllData() {
        // Создаем данные
        let journalRecord = JournalRecord(
            filmName: "Test Film",
            developerName: "Test Developer"
        )
        coreDataService.saveJournalRecord(journalRecord)
        
        // Проверяем, что данные созданы
        var records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 1, "Should have one record before clearing")
        
        // Очищаем все данные
        XCTAssertNoThrow(coreDataService.clearAllData())
        
        // Проверяем, что данные очищены
        records = coreDataService.getCalculationRecords()
        XCTAssertEqual(records.count, 0, "Should have no records after clearing")
    }
} 