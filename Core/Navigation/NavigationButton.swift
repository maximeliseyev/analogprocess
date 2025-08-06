import SwiftUI

// MARK: - Navigation Button Component
struct NavigationButton: View {
    let index: Int
    let onTap: () -> Void
    let backgroundColor: Color
    
    init(index: Int, onTap: @escaping () -> Void, backgroundColor: Color = Color(uiColor: .systemGray6)) {
        self.index = index
        self.onTap = onTap
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: iconName(for: index))
                    .font(.system(size: 28, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .foregroundColor(iconColor(for: index))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title(for: index))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle(for: index))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(backgroundColor)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Methods
    private func title(for idx: Int) -> String {
        guard let buttonData = NavigationButtonData.allButtons.first(where: { $0.index == idx }) else {
            return ""
        }
        return String(localized: String.LocalizationValue(buttonData.titleKey))
    }
    
    private func subtitle(for idx: Int) -> String {
        guard let buttonData = NavigationButtonData.allButtons.first(where: { $0.index == idx }) else {
            return ""
        }
        return String(localized: String.LocalizationValue(buttonData.subtitleKey))
    }
    
    private func iconName(for idx: Int) -> String {
        guard let buttonData = NavigationButtonData.allButtons.first(where: { $0.index == idx }) else {
            return "square"
        }
        return buttonData.iconName
    }
    
    private func iconColor(for idx: Int) -> Color {
        guard let buttonData = NavigationButtonData.allButtons.first(where: { $0.index == idx }) else {
            return .gray
        }
        return buttonData.iconColor
    }
} 