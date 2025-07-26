import SwiftUI

struct HomeView: View {
    var onSelectTab: (Int) -> Void
    @State private var showSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Spacer()
                ForEach(0..<4) { idx in
                    Button(action: { onSelectTab(idx) }) {
                        HStack {
                            Image(systemName: iconName(for: idx))
                                .font(.title)
                            Text(title(for: idx))
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(Color(.systemGray5))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                }
                Spacer()
            }
            .navigationTitle(LocalizedStringKey("filmClaculator"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    func title(for idx: Int) -> String {
        switch idx {
        case 0: return NSLocalizedString("presets", comment: "")
        case 1: return NSLocalizedString("calculator", comment: "")
        case 2: return NSLocalizedString("timer", comment: "")
        case 3: return NSLocalizedString("journal", comment: "")
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
} 