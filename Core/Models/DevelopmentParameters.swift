//
//  DevelopmentParameters.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation
import CoreData

struct DevelopmentParameters {
    let film: Film
    let developer: Developer
    let dilution: String
    let temperature: Double
    let iso: Int
    
    init(film: Film, developer: Developer, dilution: String, temperature: Double, iso: Int) {
        self.film = film
        self.developer = developer
        self.dilution = dilution
        self.temperature = temperature
        self.iso = iso
    }
} 