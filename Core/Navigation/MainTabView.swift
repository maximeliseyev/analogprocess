import SwiftUI
import CoreData


public struct MainTabView: View {
    @Binding var selectedTab: Int
    var onBackToHome: () -> Void
    @StateObject private var coreDataService = CoreDataService.shared
    @State private var savedRecords: [CalculationRecord] = []
    @Binding var colorScheme: ColorScheme?
    @State private var showManuals = false
    
    public var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DevelopmentSetupView()
                    .tabItem {
                        Image(systemName: "slider.horizontal.3")
                        Text(LocalizedStringKey("presets"))
                    }
                    .tag(0)
                
                CalculatorView()
                    .tabItem {
                        Image(systemName: "plus.forwardslash.minus")
                        Text(LocalizedStringKey("calculator"))
                    }
                    .tag(1)
                
                TimerTabView()
                    .tabItem {
                        Image(systemName: "timer")
                        Text(LocalizedStringKey("timer"))
                    }
                    .tag(2)
                
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
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: onBackToHome) {
                Image(systemName: "house")
                    .foregroundColor(.blue)
            })
            .onChange(of: selectedTab) { newValue in
                if newValue == 4 {
                    showManuals = true
                    selectedTab = 0 // Возвращаемся к первому табу
                }
            }
            .sheet(isPresented: $showManuals) {
                ManualView()
            }
        }
    }
    
    public init(selectedTab: Binding<Int>, onBackToHome: @escaping () -> Void, colorScheme: Binding<ColorScheme?>) {
        self._selectedTab = selectedTab
        self.onBackToHome = onBackToHome
        self._colorScheme = colorScheme
    }
    
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
