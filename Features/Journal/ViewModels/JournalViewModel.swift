//
//  SwiftDataJournalViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var savedRecords: [SwiftDataJournalRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var syncStatus: CloudKitService.SyncStatus = .idle
    @Published var isCloudAvailable = false
    
    // MARK: - Dependencies
    let swiftDataService: SwiftDataService
    private let cloudKitService: CloudKitService
    private var cancellables = Set<AnyCancellable>()
    private var notificationCenter = NotificationCenter.default
    
    init(swiftDataService: SwiftDataService, cloudKitService: CloudKitService) {
        self.swiftDataService = swiftDataService
        self.cloudKitService = cloudKitService
        setupCloudKitObservers()
        loadRecords()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
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
        
        loadSwiftDataRecords()
        
        isLoading = false
    }
    
    private func loadSwiftDataRecords() {
        savedRecords = swiftDataService.getCalculationRecords()
    }
    
    func deleteRecord(_ record: SwiftDataJournalRecord) {
        swiftDataService.deleteCalculationRecord(record)
        loadRecords()
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
