//
//  NetworkConstants.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// MARK: - Network Constants
public enum NetworkConstants {
    static let baseURL: String = {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "GitHubDataRepoURL") as? String else {
            return "https://raw.githubusercontent.com/maximeliseyev/filmdevelopmentdata/main"
        }
        return url
    }()
    
    static let filmsEndpoint = "/films.json"
    static let developersEndpoint = "/developers.json"
    static let fixersEndpoint = "/fixers.json"
    static let developmentTimesEndpoint = "/development-times.json"
    static let temperatureMultipliersEndpoint = "/temperature-multipliers.json"
    static let agitationModesEndpoint = "/agitation-modes.json"
}