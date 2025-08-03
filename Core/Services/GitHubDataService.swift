//
//  GitHubDataService.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import Combine

public class GitHubDataService: ObservableObject {
    public static let shared = GitHubDataService()
    
    private let baseURL = "https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main"
    private let session = URLSession.shared
    
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    @Published var lastSyncDate: Date?
    
    private init() {
        loadLastSyncDate()
    }
    
    // MARK: - Data Download
    
    func downloadAllData() async throws -> GitHubData {
        await MainActor.run {
            isDownloading = true
            downloadProgress = 0.0
        }
        
        defer {
            Task { @MainActor in
                isDownloading = false
                downloadProgress = 0.0
            }
        }
        
        async let filmsData = downloadFilms()
        async let developersData = downloadDevelopers()
        async let developmentTimesData = downloadDevelopmentTimes()
        async let temperatureMultipliersData = downloadTemperatureMultipliers()
        
        let (films, developers, developmentTimes, temperatureMultipliers) = try await (filmsData, developersData, developmentTimesData, temperatureMultipliersData)
        
        await MainActor.run {
            downloadProgress = 1.0
            lastSyncDate = Date()
            saveLastSyncDate()
        }
        
        return GitHubData(
            films: films,
            developers: developers,
            developmentTimes: developmentTimes,
            temperatureMultipliers: temperatureMultipliers
        )
    }
    
    private func downloadFilms() async throws -> [String: [String: Any]] {
        let url = URL(string: "\(baseURL)/films.json")!
        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] ?? [:]
        
        await MainActor.run {
            downloadProgress += 0.25
        }
        
        return json
    }
    
    private func downloadDevelopers() async throws -> [String: [String: Any]] {
        let url = URL(string: "\(baseURL)/developers.json")!
        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] ?? [:]
        
        await MainActor.run {
            downloadProgress += 0.25
        }
        
        return json
    }
    
    private func downloadDevelopmentTimes() async throws -> [String: [String: [String: [String: Int]]]] {
        let url = URL(string: "\(baseURL)/development-times.json")!
        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: [String: [String: Int]]]] ?? [:]
        
        await MainActor.run {
            downloadProgress += 0.25
        }
        
        return json
    }
    
    private func downloadTemperatureMultipliers() async throws -> [String: Double] {
        let url = URL(string: "\(baseURL)/temperature-multipliers.json")!
        let (data, _) = try await session.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Double] ?? [:]
        
        await MainActor.run {
            downloadProgress += 0.25
        }
        
        return json
    }
    
    // MARK: - Sync Date Management
    
    private func loadLastSyncDate() {
        if let date = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date {
            lastSyncDate = date
        }
    }
    
    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
    }
}

// MARK: - Data Models

public struct GitHubData {
    let films: [String: [String: Any]]
    let developers: [String: [String: Any]]
    let developmentTimes: [String: [String: [String: [String: Int]]]]
    let temperatureMultipliers: [String: Double]
} 