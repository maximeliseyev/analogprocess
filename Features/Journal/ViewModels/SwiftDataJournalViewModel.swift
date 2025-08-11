//
//  SwiftDataJournalViewModel.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 11.08.2025.
//

import SwiftUI
import CoreData
import SwiftData
import Combine

@MainActor
class SwiftDataJournalViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var savedRecords: [CalculationRecord] = []
    @Published var savedSwiftDataRecords: [SwiftDataCalculationRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var syncStatus: CloudKitService.SyncStatus = .idle
    @Published var isCloudAvailable = false
    
    // MARK: - Data Mode
    @Published var useSwiftData: Bool = false
    
    // MARK: - Dependencies
    private let coreDataService = CoreDataService.shared
    private let swiftDataService = SwiftDataService.shared
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
    
    // MARK: - Data Mode Methods
    
    func toggleDataMode() {
        useSwiftData.toggle()
        print("DEBUG: Journal switched to \(useSwiftData ? "SwiftData" : "Core Data") mode")
        loadRecords()
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
        // Обновляем записи при любых изменениях в контексте (только для Core Data)
        if !useSwiftData {
            DispatchQueue.main.async {
                self.loadRecords()
            }
        }
    }
    
    @objc private func managedObjectContextDidSave(_ notification: Notification) {
        // Обновляем записи после сохранения контекста (только для Core Data)
        if !useSwiftData {
            DispatchQueue.main.async {
                self.loadRecords()
            }
        }
    }
    
    // MARK: - Methods
    
    func loadRecords() {
        isLoading = true
        errorMessage = nil
        
        if useSwiftData {
            loadSwiftDataRecords()
        } else {
            loadCoreDataRecords()
        }
        
        isLoading = false
    }
    
    private func loadCoreDataRecords() {
        savedRecords = coreDataService.getCalculationRecords()
    }
    
    private func loadSwiftDataRecords() {
        // TODO: Реализовать загрузку из SwiftData
        // Пока используем заглушку
        savedSwiftDataRecords = []
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        coreDataService.deleteCalculationRecord(record)
        // loadRecords() вызывается автоматически через notification
    }
    
    func deleteSwiftDataRecord(_ record: SwiftDataCalculationRecord) {
        // TODO: Реализовать удаление из SwiftData
        print("DEBUG: Deleting SwiftData record - \(record.name)")
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
