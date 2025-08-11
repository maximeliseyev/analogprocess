//
//  GitHubDataService.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

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
        isDownloading = true
        downloadProgress = Constants.Progress.initialProgress
        
        defer {
            isDownloading = false
            downloadProgress = Constants.Progress.initialProgress
        }
        
        async let filmsData = downloadFilms()
        async let developersData = downloadDevelopers()
        async let developmentTimesData = downloadDevelopmentTimes()
        async let temperatureMultipliersData = downloadTemperatureMultipliers()
        
        let (films, developers, developmentTimes, temperatureMultipliers) = try await (filmsData, developersData, developmentTimesData, temperatureMultipliersData)
        
        downloadProgress = Constants.Progress.maxProgress
        lastSyncDate = Date()
        saveLastSyncDate()
        
        return GitHubDataResponse(
            films: films,
            developers: developers,
            developmentTimes: developmentTimes,
            temperatureMultipliers: temperatureMultipliers
        )
    }
    
    private func downloadFilms() async throws -> [String: FilmData] {
        let url = URL(string: Constants.Network.baseURL + Constants.Network.filmsEndpoint)!
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let films = try jsonDecoder.decode([String: FilmData].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return films
        } catch {
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadDevelopers() async throws -> [String: DeveloperData] {
        let url = URL(string: Constants.Network.baseURL + Constants.Network.developersEndpoint)!
        let (data, response) = try await networkSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubDataServiceError.networkError(.invalidResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GitHubDataServiceError.networkError(.serverError(httpResponse.statusCode))
        }
        
        do {
            let developers = try jsonDecoder.decode([String: DeveloperData].self, from: data)
            downloadProgress += Constants.Progress.downloadStepIncrement
            return developers
        } catch {
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadDevelopmentTimes() async throws -> [String: [String: [String: [String: Int]]]] {
        let url = URL(string: Constants.Network.baseURL + Constants.Network.developmentTimesEndpoint)!
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
            throw GitHubDataServiceError.decodingError
        }
    }
    
    private func downloadTemperatureMultipliers() async throws -> [String: Double] {
        let url = URL(string: Constants.Network.baseURL + Constants.Network.temperatureMultipliersEndpoint)!
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