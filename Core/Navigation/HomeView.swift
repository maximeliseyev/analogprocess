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
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                ForEach(0..<4, id: \.self) { idx in
                    Button(action: {
                        onSelectTab(idx)
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
    
    public init(onSelectTab: @escaping (Int) -> Void, colorScheme: Binding<ColorScheme?>) {
        self.onSelectTab = onSelectTab
        self._colorScheme = colorScheme
    }
} 
