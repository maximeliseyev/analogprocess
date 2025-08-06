import SwiftUI

public struct HomeView: View {
    var onSelectTab: (Int) -> Void
    @Binding var colorScheme: ColorScheme?
    @State private var showSettings = false
    
    public var body: some View {
        NavigationStack {
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
                    NavigationButton(
                        index: idx,
                        onTap: { onSelectTab(idx) },
                        backgroundColor: Color(uiColor: .systemGray6)
                    )
                }
                
                Spacer()
            }
            .navigationTitle(LocalizedStringKey("main_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView(colorScheme: $colorScheme)) {
                        Image(systemName: "gearshape")
                    }
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
    
    
    public init(onSelectTab: @escaping (Int) -> Void, colorScheme: Binding<ColorScheme?>) {
        self.onSelectTab = onSelectTab
        self._colorScheme = colorScheme
    }
} 
