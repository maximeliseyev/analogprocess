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
    private var notificationCenter = NotificationCenter.default
    
    init() {
        setupCloudKitObservers()
        setupCoreDataObservers()
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
    
    private func setupCoreDataObservers() {
        // Наблюдаем за изменениями в Core Data
        notificationCenter.addObserver(
            self,
            selector: #selector(managedObjectContextObjectsDidChange),
            name: .NSManagedObjectContextObjectsDidChange,
            object: coreDataService.container.viewContext
        )
        
        // Наблюдаем за сохранением контекста
        notificationCenter.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: coreDataService.container.viewContext
        )
    }
    
    // MARK: - Notification Handlers
    
    @objc private func managedObjectContextObjectsDidChange(_ notification: Notification) {
        // Обновляем записи при любых изменениях в контексте
        DispatchQueue.main.async {
            self.loadRecords()
        }
    }
    
    @objc private func managedObjectContextDidSave(_ notification: Notification) {
        // Обновляем записи после сохранения контекста
        DispatchQueue.main.async {
            self.loadRecords()
        }
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
        // loadRecords() вызывается автоматически через notification
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