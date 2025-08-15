//
//  DevelopmentParameters.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import SwiftData

struct DevelopmentParameters {
    let film: SwiftDataFilm
    let developer: SwiftDataDeveloper
    let dilution: String
    let temperature: Int
    let iso: Int
    
    init(film: SwiftDataFilm, developer: SwiftDataDeveloper, dilution: String, temperature: Int, iso: Int) {
        self.film = film
        self.developer = developer
        self.dilution = dilution
        self.temperature = temperature
        self.iso = iso
    }
} 