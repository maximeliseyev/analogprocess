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
    @Published var savedRecords: [SwiftDataCalculationRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var syncStatus: CloudKitService.SyncStatus = .idle
    @Published var isCloudAvailable = false
    
    // MARK: - Dependencies
    private let swiftDataService = SwiftDataService.shared
    private let cloudKitService = CloudKitService.shared
    private var cancellables = Set<AnyCancellable>()
    private var notificationCenter = NotificationCenter.default
    
    init() {
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
    
    func deleteRecord(_ record: SwiftDataCalculationRecord) {
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
