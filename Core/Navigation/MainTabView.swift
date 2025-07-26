//
//  MainTabView.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import SwiftUI
import CoreData

struct TimerTabView: View {
    @State private var showTimer = false
    @State private var timerMinutes = 0
    @State private var timerSeconds = 0
    @State private var timerLabel = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text(LocalizedStringKey("timer"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(LocalizedStringKey("selectDevelopmentParameters"))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    // Здесь можно добавить логику для настройки таймера
                    showTimer = true
                }) {
                    HStack {
                        Image(systemName: "timer")
                            .font(.title2)
                        Text(LocalizedStringKey("startTimer"))
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .sheet(isPresented: $showTimer) {
                TimerView(
                    timerLabel: timerLabel.isEmpty ? "Development Timer" : timerLabel,
                    totalMinutes: timerMinutes,
                    totalSeconds: timerSeconds,
                    onClose: { showTimer = false }
                )
            }
        }
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    @StateObject private var coreDataService = CoreDataService.shared
    @State private var savedRecords: [CalculationRecord] = []
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Пресеты - настройка проявки
            DevelopmentSetupView()
                .tabItem {
                    Image(systemName: "slider.horizontal.3")
                    Text(LocalizedStringKey("presets"))
                }
                .tag(0)
            
            // Калькулятор времени
            CalculatorView()
                .tabItem {
                    Image(systemName: "plus.forwardslash.minus")
                    Text(LocalizedStringKey("calculator"))
                }
                .tag(1)
            
            // Таймер
            TimerTabView()
                .tabItem {
                    Image(systemName: "timer")
                    Text(LocalizedStringKey("timer"))
                }
                .tag(2)
            
            // Журнал записей
            JournalView(
                records: savedRecords,
                onLoadRecord: loadRecord,
                onDeleteRecord: deleteRecord,
                onClose: { }
            )
            .tabItem {
                Image(systemName: "book")
                Text(LocalizedStringKey("journal"))
            }
            .tag(3)
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