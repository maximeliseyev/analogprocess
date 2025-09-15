import SwiftUI

struct AgitationPhaseConfigView: View {
    @Binding var config: AgitationPhaseConfig
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Type selector
            typeSelector
            
            // Timing controls (for cycle and periodic types)
            if config.type.requiresTiming {
                timingControls
            }
            
            // Custom description (for custom type)
            if config.type.requiresCustomDescription {
                customDescriptionField
            }
            
            // Preview
            phasePreview
        }
    }
    
    // MARK: - View Components
    
    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("agitationType"))
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(AgitationPhaseConfig.PhaseType.allCases) { type in
                    Button(action: {
                        config.type = type
                        // Reset values when type changes
                        resetConfigForType(type)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: iconForType(type))
                                .font(.title3)
                            
                            Text(type.localizedName)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(
                            config.type == type ? 
                            Color.blue.opacity(0.2) : 
                            Color(.systemGray5)
                        )
                        .foregroundColor(
                            config.type == type ? .blue : .primary
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    config.type == type ? Color.blue : Color.clear, 
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var timingControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            if config.type == .cycle {
                cycleTimingControls
            } else if config.type == .periodic {
                periodicTimingControls
            }
        }
    }
    
    private var cycleTimingControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("cycleTimingSettings"))
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("agitationSeconds"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("0", value: $config.agitationSeconds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Text(LocalizedStringKey("seconds"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey("restSeconds"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("0", value: $config.restSeconds, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                        
                        Text(LocalizedStringKey("seconds"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Stepper controls for easier adjustment
            VStack(spacing: 8) {
                HStack {
                    Text(LocalizedStringKey("agitationSeconds"))
                    Spacer()
                    Stepper("", value: $config.agitationSeconds, in: 0...120, step: 5)
                        .labelsHidden()
                }
                
                HStack {
                    Text(LocalizedStringKey("restSeconds"))
                    Spacer()
                    Stepper("", value: $config.restSeconds, in: 0...300, step: 5)
                        .labelsHidden()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var periodicTimingControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("periodicInterval"))
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                TextField("10", value: $config.agitationSeconds, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                
                Text(LocalizedStringKey("seconds"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Stepper("", value: $config.agitationSeconds, in: 1...60, step: 1)
                    .labelsHidden()
            }
        }
    }
    
    private var customDescriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(LocalizedStringKey("customAgitationInstructions"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("*")
                    .foregroundColor(.red)
            }
            
            TextField(
                LocalizedStringKey("customAgitationInstructionsPlaceholder"), 
                text: Binding(
                    get: { config.customDescription ?? "" },
                    set: { config.customDescription = $0.isEmpty ? nil : $0 }
                ),
                axis: .vertical
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .lineLimit(2...4)
        }
    }
    
    private var phasePreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("preview"))
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: iconForType(config.type))
                    .foregroundColor(.blue)
                
                Text(previewText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Helper Methods
    
    private func iconForType(_ type: AgitationPhaseConfig.PhaseType) -> String {
        switch type {
        case .continuous:
            return "arrow.clockwise"
        case .still:
            return "pause"
        case .cycle:
            return "repeat"
        case .periodic:
            return "timer"
        case .custom:
            return "text.alignleft"
        }
    }
    
    private func resetConfigForType(_ type: AgitationPhaseConfig.PhaseType) {
        switch type {
        case .cycle:
            if config.agitationSeconds == 0 && config.restSeconds == 0 {
                config.agitationSeconds = AgitationConstants.Default.agitationSeconds
                config.restSeconds = AgitationConstants.Default.restSeconds
            }
            config.customDescription = nil
        case .periodic:
            if config.agitationSeconds == 0 {
                config.agitationSeconds = 10
            }
            config.restSeconds = 0
            config.customDescription = nil
        case .custom:
            config.agitationSeconds = 0
            config.restSeconds = 0
            if config.customDescription?.isEmpty ?? true {
                config.customDescription = ""
            }
        case .continuous, .still:
            config.agitationSeconds = 0
            config.restSeconds = 0
            config.customDescription = nil
        }
    }
    
    private var previewText: String {
        let tempPhase = AgitationPhase(
            agitationType: createAgitationType(),
            description: ""
        )
        return tempPhase.description
    }
    
    private func createAgitationType() -> AgitationPhase.PhaseAgitationType {
        switch config.type {
        case .continuous:
            return .continuous
        case .still:
            return .still
        case .cycle:
            return .cycle(agitationSeconds: config.agitationSeconds, restSeconds: config.restSeconds)
        case .periodic:
            return .periodic(intervalSeconds: config.agitationSeconds)
        case .custom:
            return .custom(description: config.customDescription ?? "")
        }
    }
}

// MARK: - Preview

struct AgitationPhaseConfigView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AgitationPhaseConfigView(
                config: .constant(AgitationPhaseConfig(type: .cycle, agitationSeconds: 30, restSeconds: 30)),
                title: "First Minute"
            )
            .padding()
            
            AgitationPhaseConfigView(
                config: .constant(AgitationPhaseConfig(type: .custom, customDescription: "Custom instructions")),
                title: "Custom Phase"
            )
            .padding()
        }
    }
}
