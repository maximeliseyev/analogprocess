import SwiftUI

struct AgitationSelectionView: View {
    @Binding var selectedMode: AgitationMode
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header with description
                VStack(spacing: 8) {
                    Text(LocalizedStringKey("agitationDescription"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Agitation mode tabs
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(AgitationMode.presets, id: \.id) { mode in
                        AgitationModeTab(
                            mode: mode,
                            isSelected: selectedMode.id == mode.id,
                            onTap: {
                                selectedMode = mode
                                dismiss()
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Custom agitation option
                CustomAgitationTab(
                    onTap: {
                        // Handle custom agitation - you might want to navigate to custom setup
                        dismiss()
                    }
                )
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle(LocalizedStringKey("agitationSelection"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AgitationModeTab: View {
    let mode: AgitationMode
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(mode.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .primary)
                
                Text(mode.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomAgitationTab: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("customAgitation"))
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(LocalizedStringKey("customAgitationDescription"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Keep the existing preview
struct AgitationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AgitationSelectionView(selectedMode: .constant(AgitationMode.presets[1]))
    }
}
