//
//  CoreDataFixTests.swift
//  FilmLab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import XCTest
@testable import FilmLab

final class CoreDataFixTests: XCTestCase {
    
    func testJournalRecordConversion() {
        // Тест конвертации JournalRecord в CalculationRecord
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
        
        // Проверяем, что конвертация работает
        XCTAssertNoThrow {
            // Создаем временный контекст для теста
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            let record = journalRecord.toCalculationRecord(context: context)
            
            // Проверяем, что данные сохранились
            XCTAssertEqual(record.name, "Test Record")
            XCTAssertEqual(record.filmName, "Test Film")
            XCTAssertEqual(record.developerName, "Test Developer")
            XCTAssertEqual(record.dilution, "1+1")
            XCTAssertEqual(record.temperature, 20.0)
            XCTAssertEqual(record.time, 300)
            XCTAssertEqual(record.comment, "Test comment")
        }
    }
    
    func testUnusedResultHandling() {
        // Тест обработки неиспользуемого результата
        let journalRecord = JournalRecord(
            filmName: "Test Film",
            developerName: "Test Developer"
        )
        
        // Проверяем, что можно игнорировать результат
        XCTAssertNoThrow {
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            _ = journalRecord.toCalculationRecord(context: context)
        }
    }
    
    func testCoreDataContextHandling() {
        // Тест работы с контекстом CoreData
        XCTAssertNoThrow {
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
            // Проверяем, что контекст создается без ошибок
            XCTAssertNotNil(context)
            
            // Проверяем, что можно сохранить контекст
            if context.hasChanges {
                XCTAssertNoThrow(try context.save())
            }
        }
    }
    
    func testJournalRecordInitialization() {
        // Тест инициализации JournalRecord
        XCTAssertNoThrow {
            let record = JournalRecord(
                date: Date(),
                name: "Test",
                filmName: "Film",
                developerName: "Developer",
                dilution: "1+1",
                temperature: 20.0,
                time: 300,
                comment: "Comment"
            )
            
            XCTAssertEqual(record.name, "Test")
            XCTAssertEqual(record.filmName, "Film")
            XCTAssertEqual(record.developerName, "Developer")
        }
    }
    
    func testOptionalFields() {
        // Тест опциональных полей
        XCTAssertNoThrow {
            let record = JournalRecord(
                filmName: "Film",
                developerName: "Developer"
            )
            
            XCTAssertNil(record.name)
            XCTAssertNil(record.comment)
            XCTAssertEqual(record.filmName, "Film")
            XCTAssertEqual(record.developerName, "Developer")
        }
    }
} 