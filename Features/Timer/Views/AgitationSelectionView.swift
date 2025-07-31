import SwiftUI

struct AgitationSelectionView: View {
    @Binding var selectedMode: AgitationMode
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AgitationMode.presets, id: \.id) { mode in
                        Button(action: {
                            selectedMode = mode
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mode.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(mode.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedMode.id == mode.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Agitation Mode")
            .navigationBarTitleDisplayMode(.inline)
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
        AgitationSelectionView(selectedMode: .constant(AgitationMode.presets[0]))
    }
}
