import SwiftUI
import Combine
import SwiftData

public struct MainTabView: View {
    let swiftDataService: SwiftDataService
    
    @Binding var selectedTab: Int
    @Binding var colorScheme: ColorScheme?
    
    private let cloudKitService = CloudKitService.shared
    @State private var showingCreateRecord = false
    @State private var syncStatus: CloudKitService.SyncStatus = .idle
    @State private var isCloudAvailable = false
    
    // Staging ViewModel для сохранения состояния между навигацией
    @StateObject private var stagingViewModel = StagingViewModel()
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                homeView
            }
            .tabItem {
                Image(systemName: "house")
                Text(LocalizedStringKey("home"))
            }
            .tag(0)
            
            NavigationStack {
                JournalView(
                    swiftDataService: swiftDataService,
                    cloudKitService: cloudKitService,
                    onEditRecord: loadRecord,
                    onDeleteRecord: deleteRecord,
                    onCreateNew: { showingCreateRecord = true },
                    syncStatus: syncStatus,
                    isCloudAvailable: isCloudAvailable,
                    onSync: {
                        Task {
                            await cloudKitService.syncRecords()
                        }
                    }
                )
            }
            .tabItem {
                Image(systemName: "book")
                Text(LocalizedStringKey("journal"))
            }
            .tag(1)
            
            NavigationStack {
                SettingsView(colorScheme: $colorScheme)
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text(LocalizedStringKey("settings"))
            }
            .tag(2)
        }
        .accentColor(.blue)
        .onAppear(perform: setupCloudKitObservers)
        .sheet(isPresented: $showingCreateRecord) {
            CreateRecordView(
                swiftDataService: swiftDataService,
                prefillData: nil,
                isEditing: false,
                onUpdate: nil,
                calculatorTemperature: nil,
                calculatorCoefficient: nil,
                calculatorProcess: nil
            )
        }
    }
    
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
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private var homeView: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("mainTitle"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(LocalizedStringKey("homeDescription"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(Color.clear)

            Section {
                NavigationLink(destination: StagingView(viewModel: stagingViewModel)) {
                    homeCard(
                        title: LocalizedStringKey("startProcess"),
                        subtitle: LocalizedStringKey("startProcessSubtitle"),
                        iconName: "list.bullet.rectangle.portrait",
                        iconColor: .blue
                    )
                }
            }
            
            Section(header: Text(LocalizedStringKey("tools"))) {
                NavigationLink(destination: ToolsHubView(swiftDataService: swiftDataService)) {
                     homeCard(
                        title: LocalizedStringKey("tools"),
                        subtitle: LocalizedStringKey("toolsSubtitle"),
                        iconName: "wrench.and.screwdriver",
                        iconColor: .orange
                    )
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(LocalizedStringKey("home"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func homeCard(title: LocalizedStringKey, subtitle: LocalizedStringKey, iconName: String, iconColor: Color) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 36, height: 36)
                .foregroundColor(iconColor)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func loadRecord(_ record: SwiftDataJournalRecord) {
        print("Loading record: \(record)")
    }
    
    private func deleteRecord(_ record: SwiftDataJournalRecord) {
        swiftDataService.deleteCalculationRecord(record)
    }
    
    public init(swiftDataService: SwiftDataService, selectedTab: Binding<Int>, colorScheme: Binding<ColorScheme?>) {
        self.swiftDataService = swiftDataService
        self._selectedTab = selectedTab
        self._colorScheme = colorScheme
    }
}
