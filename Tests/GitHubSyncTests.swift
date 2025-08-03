//
//  GitHubSyncTests.swift
//  FilmLab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import XCTest
@testable import FilmLab

final class GitHubSyncTests: XCTestCase {
    
    var githubService: GitHubDataService!
    
    override func setUp() {
        super.setUp()
        githubService = GitHubDataService.shared
    }
    
    override func tearDown() {
        githubService = nil
        super.tearDown()
    }
    
    func testGitHubDataDownload() async throws {
        // Тест загрузки данных из GitHub
        let data = try await githubService.downloadAllData()
        
        // Проверяем, что данные загружены
        XCTAssertFalse(data.films.isEmpty, "Films data should not be empty")
        XCTAssertFalse(data.developers.isEmpty, "Developers data should not be empty")
        XCTAssertFalse(data.developmentTimes.isEmpty, "Development times data should not be empty")
        XCTAssertFalse(data.temperatureMultipliers.isEmpty, "Temperature multipliers data should not be empty")
        
        // Проверяем структуру данных
        for (filmId, filmData) in data.films {
            XCTAssertNotNil(filmData["name"], "Film should have name")
            XCTAssertNotNil(filmData["manufacturer"], "Film should have manufacturer")
            XCTAssertNotNil(filmData["type"], "Film should have type")
            XCTAssertNotNil(filmData["defaultISO"], "Film should have defaultISO")
        }
        
        for (developerId, developerData) in data.developers {
            XCTAssertNotNil(developerData["name"], "Developer should have name")
            XCTAssertNotNil(developerData["manufacturer"], "Developer should have manufacturer")
            XCTAssertNotNil(developerData["type"], "Developer should have type")
            XCTAssertNotNil(developerData["defaultDilution"], "Developer should have defaultDilution")
        }
    }
    
    func testSyncProgress() async throws {
        // Тест прогресса загрузки
        let expectation = XCTestExpectation(description: "Download progress")
        
        Task {
            do {
                _ = try await githubService.downloadAllData()
                expectation.fulfill()
            } catch {
                XCTFail("Download failed: \(error)")
            }
        }
        
        // Проверяем, что прогресс обновляется
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertGreaterThanOrEqual(self.githubService.downloadProgress, 0.0)
            XCTAssertLessThanOrEqual(self.githubService.downloadProgress, 1.0)
        }
        
        await fulfillment(of: [expectation], timeout: 30.0)
    }
    
    func testLastSyncDate() {
        // Тест сохранения даты последней синхронизации
        let testDate = Date()
        githubService.lastSyncDate = testDate
        
        // Проверяем, что дата сохранилась
        XCTAssertEqual(githubService.lastSyncDate, testDate)
    }
} 