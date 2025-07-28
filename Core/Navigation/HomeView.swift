import SwiftUI

public struct HomeView: View {
    var onSelectTab: (Int) -> Void
    @Binding var colorScheme: ColorScheme?
    @State private var showSettings = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                Text(LocalizedStringKey("home_description"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                
                ForEach(0..<5, id: \.self) { idx in
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
        case 0: return NSLocalizedString("presets", comment: "")
        case 1: return NSLocalizedString("calculator", comment: "")
        case 2: return NSLocalizedString("timer", comment: "")
        case 3: return NSLocalizedString("journal", comment: "")
        case 4: return NSLocalizedString("manuals", comment: "")
        default: return "" }
    }
    
    func subtitle(for idx: Int) -> String {
        switch idx {
        case 0: return NSLocalizedString("home_presets_subtitle", comment: "")
        case 1: return NSLocalizedString("home_calculator_subtitle", comment: "")
        case 2: return NSLocalizedString("home_timer_subtitle", comment: "")
        case 3: return NSLocalizedString("home_journal_subtitle", comment: "")
        case 4: return NSLocalizedString("home_manuals_subtitle", comment: "")
        default: return "" }
    }
    
    func iconName(for idx: Int) -> String {
        switch idx {
        case 0: return "slider.horizontal.3"
        case 1: return "plus.forwardslash.minus"
        case 2: return "timer"
        case 3: return "book"
        case 4: return "folder"
        default: return "square"
        }
    }
    
    func iconColor(for idx: Int) -> Color {
        switch idx {
        case 0: return .blue
        case 1: return .orange
        case 2: return .red
        case 3: return .purple
        case 4: return .yellow
        default: return .gray
        }
    }
    
    public init(onSelectTab: @escaping (Int) -> Void, colorScheme: Binding<ColorScheme?>) {
        self.onSelectTab = onSelectTab
        self._colorScheme = colorScheme
    }
} 
