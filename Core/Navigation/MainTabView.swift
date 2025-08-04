import SwiftUI
import CoreData

public struct MainTabView: View {
    @Binding var selectedTab: Int
    var onBackToHome: () -> Void
    @Binding var colorScheme: ColorScheme?
    
    private let dataService = CoreDataService.shared
    @State private var savedRecords: [CalculationRecord] = []
    @State private var showingCreateRecord = false

    
    public var body: some View {
        NavigationStack {
            if selectedTab == 0 {
                // Главный экран без TabView
                mainScreenView
            } else {
                // Остальные экраны с TabView
                TabView(selection: $selectedTab) {
                    // Экран Development
                    DevelopmentSetupView()
                        .tabItem {
                            Image(systemName: "slider.horizontal.3")
                            Text(LocalizedStringKey("presets"))
                        }
                        .tag(1)
                    
                    // Экран Calculator
                    CalculatorView(onStartTimer: { _, _, _ in })
                        .tabItem {
                            Image(systemName: "plus.forwardslash.minus")
                            Text(LocalizedStringKey("calculator"))
                        }
                        .tag(2)
                    
                    // Экран Timer
                    TimerTabView()
                        .tabItem {
                            Image(systemName: "timer")
                            Text(LocalizedStringKey("timer"))
                        }
                        .tag(3)
                    
                    // Экран Journal
                    JournalView(
                        records: savedRecords,
                        onEditRecord: loadRecord,
                        onDeleteRecord: deleteRecord,
                        onClose: goToHome,
                        onCreateNew: {
                            showingCreateRecord = true
                        }
                    )
                    .tabItem {
                        Image(systemName: "book")
                        Text(LocalizedStringKey("journal"))
                    }
                    .tag(4)
                }
                .accentColor(.blue)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: goToHome) {
                            Image(systemName: "house")
                                .foregroundColor(.blue)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if selectedTab == 4 {
                            Button(action: {
                                showingCreateRecord = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadRecords()
        }
        .sheet(isPresented: $showingCreateRecord) {
            CreateRecordView()
                .onDisappear {
                    loadRecords() // Обновляем список после создания записи
                }
        }

    }
    
    private func goToHome() {
        selectedTab = 0
    }
    

    
    // Главный экран с описанием и кнопками
    private var mainScreenView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text(LocalizedStringKey("home_description"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                ForEach(0..<4, id: \.self) { idx in
                    Button(action: {
                        selectedTab = idx + 1 // +1 потому что 0 - это главный экран
                    }) {
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: iconName(for: idx))
                                .font(.system(size: 28, weight: .semibold))
                                .frame(width: 36, height: 36)
                                .foregroundColor(iconColor(for: idx))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title(for: idx))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text(subtitle(for: idx))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 18)
                        .padding(.horizontal, 20)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle(LocalizedStringKey("filmLab"))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(colorScheme: $colorScheme)) {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
    
    func title(for idx: Int) -> String {
        switch idx {
        case 0: return String(localized: "presets")
        case 1: return String(localized: "calculator")
        case 2: return String(localized: "timer")
        case 3: return String(localized: "journal")
        default: return "" }
    }
    
    func subtitle(for idx: Int) -> String {
        switch idx {
        case 0: return String(localized: "home_presets_subtitle")
        case 1: return String(localized: "home_calculator_subtitle")
        case 2: return String(localized: "home_timer_subtitle")
        case 3: return String(localized: "home_journal_subtitle")
        default: return "" }
    }
    
    func iconName(for idx: Int) -> String {
        switch idx {
        case 0: return "slider.horizontal.3"
        case 1: return "plus.forwardslash.minus"
        case 2: return "timer"
        case 3: return "book"
        default: return "square"
        }
    }
    
    func iconColor(for idx: Int) -> Color {
        switch idx {
        case 0: return .blue
        case 1: return .orange
        case 2: return .red
        case 3: return .purple
        default: return .gray
        }
    }
    
    func loadRecords() {
        savedRecords = dataService.getCalculationRecords()
    }
        
    func loadRecord(_ record: CalculationRecord) {
        // Здесь можно добавить логику загрузки записи в калькулятор
        print("Loading record: \(record)")
    }
    
    func deleteRecord(_ record: CalculationRecord) {
        dataService.deleteCalculationRecord(record)
        loadRecords()
    }
    
    public init(selectedTab: Binding<Int>, onBackToHome: @escaping () -> Void, colorScheme: Binding<ColorScheme?>) {
        self._selectedTab = selectedTab
        self.onBackToHome = onBackToHome
        self._colorScheme = colorScheme
    }
}
