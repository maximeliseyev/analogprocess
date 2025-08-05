//
//  JournalViewModel.swift
//  Film Lab
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var savedRecords: [CalculationRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var syncStatus: CloudKitService.SyncStatus = .idle
    @Published var isCloudAvailable = false
    
    // MARK: - Dependencies
    private let coreDataService = CoreDataService.shared
    private let cloudKitService = CloudKitService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupCloudKitObservers()
    }
    
    // MARK: - Setup
    
    private func setupCloudKitObservers() {
        cloudKitService.$syncStatus
            .receive(on: DispatchQueue.main)
            .assign(to: \.syncStatus, on: self)
            .store(in: &cancellables)
        
        cloudKitService.$isCloudAvailable
            .receive(on: DispatchQueue.main)
            .assign(to: \.isCloudAvailable, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    func loadRecords() {
        isLoading = true
        errorMessage = nil
        
        savedRecords = coreDataService.getCalculationRecords()
        isLoading = false
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        coreDataService.deleteCalculationRecord(record)
        loadRecords() // Обновляем список записей
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - CloudKit Methods
    
    func syncWithCloud() async {
        await cloudKitService.syncRecords()
    }
    
    func requestCloudAccess() {
        cloudKitService.requestCloudAccess()
    }
    
    func forceSync() async {
        await cloudKitService.forceSync()
    }
} 