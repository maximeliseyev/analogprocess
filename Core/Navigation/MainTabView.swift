import SwiftUI
import Combine
import SwiftData

public struct MainTabView: View {
    @Binding var selectedTab: Int
    var onBackToHome: () -> Void
    @Binding var colorScheme: ColorScheme?

    
    private let cloudKitService = CloudKitService.shared
    @State private var showingCreateRecord = false
    @State private var syncStatus: CloudKitService.SyncStatus = .idle
    @State private var isCloudAvailable = false
    @State private var useSwiftDataDevelopmentView = false

    
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
                    
                    // Экран Staging
                    StagingView()
                        .tabItem {
                            Image(systemName: "list.bullet.rectangle")
                            Text(LocalizedStringKey("staging"))
                        }
                        .tag(3)
                    
                    // Экран Timer
                    TimerTabView()
                        .tabItem {
                            Image(systemName: "timer")
                            Text(LocalizedStringKey("timer"))
                        }
                        .tag(4)
                    
                    // Экран Journal
                    JournalView(
                        onEditRecord: loadRecord,
                        onDeleteRecord: deleteRecord,
                        onClose: goToHome,
                        onCreateNew: {
                            showingCreateRecord = true
                        },
                        syncStatus: syncStatus,
                        isCloudAvailable: isCloudAvailable,
                        onSync: {
                            Task {
                                await cloudKitService.syncRecords()
                            }
                        }
                    )
                    .tabItem {
                        Image(systemName: "book")
                        Text(LocalizedStringKey("journal"))
                    }
                    .tag(5)
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
            setupCloudKitObservers()
        }
        .sheet(isPresented: $showingCreateRecord) {
            CreateRecordView(
                prefillData: nil,
                isEditing: false,
                onUpdate: nil,
                calculatorTemperature: nil,
                calculatorCoefficient: nil,
                calculatorProcess: nil
            )
        }

    }
    
    private func goToHome() {
        selectedTab = 0
    }
    
    private func setupCloudKitObservers() {
        // Подписываемся на изменения статуса синхронизации
        cloudKitService.$syncStatus
            .receive(on: DispatchQueue.main)
            .assign(to: \.syncStatus, on: self)
            .store(in: &cancellables)
        
        cloudKitService.$isCloudAvailable
            .receive(on: DispatchQueue.main)
            .assign(to: \.isCloudAvailable, on: self)
            .store(in: &cancellables)
    }
    
    @State private var cancellables = Set<AnyCancellable>()

    
    // Главный экран с описанием и кнопками
    private var mainScreenView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("mainTitle"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(nil)
                }
                    
                Spacer()
                
                Text(LocalizedStringKey("homeDescription"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                ForEach(0..<5, id: \.self) { idx in
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
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
        }
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
        guard let tabInfo = TabInfo.allTabs.first(where: { $0.index == idx }) else {
            return ""
        }
        return String(localized: String.LocalizationValue(tabInfo.titleKey))
    }
    
    func subtitle(for idx: Int) -> String {
        guard let tabInfo = TabInfo.allTabs.first(where: { $0.index == idx }) else {
            return ""
        }
        return String(localized: String.LocalizationValue(tabInfo.subtitleKey))
    }
    
    func iconName(for idx: Int) -> String {
        guard let tabInfo = TabInfo.allTabs.first(where: { $0.index == idx }) else {
            return "square"
        }
        return tabInfo.iconName
    }
    
    func iconColor(for idx: Int) -> Color {
        guard let tabInfo = TabInfo.allTabs.first(where: { $0.index == idx }) else {
            return .secondary
        }
        return tabInfo.iconColor
    }
        
    func loadRecord(_ record: SwiftDataCalculationRecord) {
        // Здесь можно добавить логику загрузки записи в калькулятор
        print("Loading record: \(record)")
    }
    
    func deleteRecord(_ record: SwiftDataCalculationRecord) {
        // Delete the record from SwiftData context
        let swiftDataService = SwiftDataService.shared
        swiftDataService.deleteCalculationRecord(record)
    }
    
    public init(selectedTab: Binding<Int>, onBackToHome: @escaping () -> Void, colorScheme: Binding<ColorScheme?>) {
        self._selectedTab = selectedTab
        self.onBackToHome = onBackToHome
        self._colorScheme = colorScheme
    }
}
