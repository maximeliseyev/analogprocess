//
//  MainTabView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var coreDataService = CoreDataService.shared
    @State private var savedRecords: [CalculationRecord] = []
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Главный экран - настройка проявки
            DevelopmentSetupView()
                .tabItem {
                    Image(systemName: "camera.aperture")
                    Text("Проявка")
                }
                .tag(0)
            
            // Калькулятор времени
            CalculatorView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("Калькулятор")
                }
                .tag(1)
            
            // Журнал записей
            JournalView(
                records: savedRecords,
                onLoadRecord: loadRecord,
                onDeleteRecord: deleteRecord,
                onClose: { }
            )
            .tabItem {
                Image(systemName: "book")
                Text("Журнал")
            }
            .tag(2)
        }
        .accentColor(.blue)
        .onAppear {
            loadRecords()
        }
    }
    
    // MARK: - Methods
    
    func loadRecords() {
        savedRecords = coreDataService.getCalculationRecords()
    }
    
    func loadRecord(_ record: CalculationRecord) {
        // Здесь можно добавить логику загрузки записи в калькулятор
        print("Loading record: \(record)")
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        coreDataService.deleteCalculationRecord(record)
        loadRecords()
    }
} 