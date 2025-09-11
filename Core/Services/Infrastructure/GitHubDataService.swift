//
//  GitHubDataService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import SwiftUI

// MARK: - GitHub Data Service Errors
public enum GitHubDataServiceError: LocalizedError {
    case invalidURL
    case networkError(NetworkError)
    case decodingError
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for data download"
        case .networkError(let error):
            return error.errorDescription
        case .decodingError:
            return "Failed to decode data from server"
        case .noData:
            return "No data received from server"
        }
    }
}

// MARK: - GitHub Data Service
@MainActor
public class GitHubDataService: ObservableObject {
    public static let shared = GitHubDataService()
    
    private let networkSession: NetworkSession
    private let jsonDecoder: JSONDecoder
    
    @Published var isDownloading = false
    @Published var downloadProgress: Double = Constants.Progress.initialProgress
    @Published var lastSyncDate: Date?
    
    public init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
        self.jsonDecoder = JSONDecoder()
        loadLastSyncDate()
    }
    
    // MARK: - Data Download
    
    public func downloadAllData() async throws -> GitHubDataResponse {
        print("DEBUG: Starting downloadAllData")
        isDownloading = true
        downloadProgress = Constants.Progress.initialProgress
        
        defer {
            isDownloading = false
            downloadProgress = Constants.Progress.initialProgress
        }
        
        do {
            async let filmsData = downloadFilms()
            async let developersData = downloadDevelopers()
            async let fixersData = downloadFixers()
            async let developmentTimesData = downloadDevelopmentTimes()
            async let temperatureMultipliersData = downloadTemperatureMultipliers()
            
            let (films, developers, fixers, developmentTimes, temperatureMultipliers) = try await (filmsData, developersData, fixersData, developmentTimesData, temperatureMultipliersData)
            
            print("DEBUG: All data downloaded successfully")
            print("DEBUG: Films count: \(films.count)")
            print("DEBUG: Developers count: \(developers.count)")
            print("DEBUG: Fixers count: \(fixers.count)")
            print("DEBUG: Development times count: \(developmentTimes.count)")
            print("DEBUG: Temperature multipliers count: \(temperatureMultipliers.count)")
            
            downloadProgress = Constants.Progress.maxProgress
            lastSyncDate = Date()
            saveLastSyncDate()
            
            return GitHubDataResponse(
                films: films,
                developers: developers,
                fixers: fixers,
                developmentTimes: developmentTimes,
                temperatureMultipliers: temperatureMultipliers
            )
        } catch {
            print("DEBUG: Error in downloadAllData: \(error)")
            throw error
        }
    }
    
    private func downloadFilms() async throws -> [String: GitHubFilmData] {
        guard let url = URL(string: Constants.Network.baseURL + Constants.Network.filmsEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let films = try jsonDecoder.decode([String: GitHubFilmData].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return films
        } catch {
            print("DEBUG: Films decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadDevelopers() async throws -> [String: GitHubDeveloperData] {
        guard let url = URL(string: Constants.Network.baseURL + Constants.Network.developersEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let developers = try jsonDecoder.decode([String: GitHubDeveloperData].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return developers
        } catch {
            print("DEBUG: Developers decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadFixers() async throws -> [String: GitHubFixerData] {
        guard let url = URL(string: Constants.Network.baseURL + Constants.Network.fixersEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let fixers = try jsonDecoder.decode([String: GitHubFixerData].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return fixers
        } catch {
            print("DEBUG: Fixer decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadDevelopmentTimes() async throws -> [String: [String: [String: [String: Int]]]] {
        guard let url = URL(string: Constants.Network.baseURL + Constants.Network.developmentTimesEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let developmentTimes = try jsonDecoder.decode([String: [String: [String: [String: Int]]]].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return developmentTimes
        } catch {
            print("DEBUG: Development times decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadTemperatureMultipliers() async throws -> [String: Double] {
        guard let url = URL(string: Constants.Network.baseURL + Constants.Network.temperatureMultipliersEndpoint) else {
            throw GitHubDataServiceError.networkError(.invalidURL)
        }
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let temperatureMultipliers = try jsonDecoder.decode([String: Double].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return temperatureMultipliers
        } catch {
            print("DEBUG: Temperature multipliers decoding error: \(error)")
            throw GitHubDataServiceError.decodingError
        }
    }
    
    // MARK: - Sync Date Management
    
    private func loadLastSyncDate() {
        if let date = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.lastSyncDate) as? Date {
            lastSyncDate = date
        }
    }
    
    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: Constants.UserDefaultsKeys.lastSyncDate)
    }
} 