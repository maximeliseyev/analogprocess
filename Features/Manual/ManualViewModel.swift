//
//  ManualViewModel.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 28.07.2025.
//


import SwiftUI
import CoreData
import Combine

@MainActor
class ManualViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // MARK: - Dependencies
    private let coreDataService = CoreDataService.shared
    
    // MARK: - Methods
    
    func loadArticles() {
    }
}
