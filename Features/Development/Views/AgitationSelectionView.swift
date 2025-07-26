import SwiftUI

struct AgitationSelectionView: View {
    let onSelect: (AgitationMode?) -> Void
    @State private var selectedMode: AgitationMode?
    @State private var showCustomAgitation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(LocalizedStringKey("agitationSelection"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text(LocalizedStringKey("agitationDescription"))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Опция "Без ажитации"
                        AgitationModeRow(
                            mode: nil,
                            isSelected: selectedMode == nil,
                            onTap: { selectedMode = nil }
                        )
                        
                        // Предустановленные режимы
                        ForEach(AgitationMode.presets, id: \.id) { mode in
                            AgitationModeRow(
                                mode: mode,
                                isSelected: selectedMode?.id == mode.id,
                                onTap: { selectedMode = mode }
                            )
                        }
                        
                        // Кастомный режим
                        CustomAgitationModeRow(
                            onTap: { showCustomAgitation = true }
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button(LocalizedStringKey("continue")) {
                    onSelect(selectedMode)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(LocalizedStringKey("skip")) {
                        onSelect(nil)
                    }
                }
            }
            .sheet(isPresented: $showCustomAgitation) {
                CustomAgitationView(
                    onSelect: { mode in
                        selectedMode = mode
                        showCustomAgitation = false
                    },
                    onCancel: {
                        showCustomAgitation = false
                    }
                )
            }
        }
    }
}

struct AgitationModeRow: View {
    let mode: AgitationMode?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode?.name ?? "No Agitation")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let mode = mode {
                        Text(mode.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    } else {
                        Text(LocalizedStringKey("noAgitationDescription"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomAgitationModeRow: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("customAgitation"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(LocalizedStringKey("customAgitationDescription"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AgitationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AgitationSelectionView { _ in }
    }
}
