
import Foundation

/// A structure to hold a preset configuration for a development process.
struct ProcessPreset {
    let name: String
    let description: String
    let stages: [StagingStage]
}

/// A service to provide predefined process presets.
class PresetService {
    
    /// Returns a list of all available standard process presets.
    static func getAvailablePresets() -> [ProcessPreset] {
        return [
            c41Preset(),
            ecn2Preset(),
            standardBwPreset()
        ]
    }
    
    // MARK: - Preset Definitions
    
    private static func c41Preset() -> ProcessPreset {
        let stages = [
            StagingStage(name: "stagingDevelopName", description: "stagingDevelopDescription", iconName: "flask.fill", color: "orange", duration: 3 * 60 + 15, temperature: 38),
            StagingStage(name: "stagingBleachName", description: "stagingBleachDescription", iconName: "flask", color: "yellow", duration: 6 * 60 + 30, temperature: 38),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan", duration: 3 * 60 + 15, temperature: 38),
            StagingStage(name: "stagingFixerName", description: "stagingFixerDescription", iconName: "shield.fill", color: "purple", duration: 6 * 60 + 30, temperature: 38),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan", duration: 3 * 60 + 15, temperature: 38),
            StagingStage(name: "stagingStabilizeName", description: "stagingStabilizeDescription", iconName: "leaf.fill", color: "green", duration: 1 * 60 + 30, temperature: 24)
        ]
        return ProcessPreset(name: "C-41", description: "Standard color negative film process.", stages: stages)
    }
    
    private static func ecn2Preset() -> ProcessPreset {
        let stages = [
            StagingStage(name: "stagingPrebathName", description: "stagingPrebathDescription", iconName: "drop.fill", color: "blue", duration: 2 * 60, temperature: 41),
            StagingStage(name: "stagingDevelopName", description: "stagingDevelopDescription", iconName: "flask.fill", color: "orange", duration: 3 * 60, temperature: 41),
            StagingStage(name: "stagingStopBathName", description: "stagingStopBathDescription", iconName: "stop.fill", color: "red", duration: 1 * 60, temperature: 41),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan", duration: 2 * 60, temperature: 41),
            StagingStage(name: "stagingBleachName", description: "stagingBleachDescription", iconName: "flask", color: "yellow", duration: 3 * 60, temperature: 38),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan", duration: 2 * 60, temperature: 38),
            StagingStage(name: "stagingFixerName", description: "stagingFixerDescription", iconName: "shield.fill", color: "purple", duration: 4 * 60, temperature: 38),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan", duration: 4 * 60, temperature: 38),
            StagingStage(name: "stagingStabilizeName", description: "stagingStabilizeDescription", iconName: "leaf.fill", color: "green", duration: 1 * 60, temperature: 24)
        ]
        return ProcessPreset(name: "ECN-2", description: "Eastman Color Negative, for motion picture film.", stages: stages)
    }
    
    private static func standardBwPreset() -> ProcessPreset {
        let stages = [
            StagingStage(name: "stagingPrebathName", description: "stagingPrebathDescription", iconName: "drop.fill", color: "blue", duration: 5 * 60, temperature: 20),
            StagingStage(name: "stagingDevelopName", description: "stagingDevelopDescription", iconName: "flask.fill", color: "orange", duration: 7 * 60, temperature: 20),
            StagingStage(name: "stagingStopBathName", description: "stagingStopBathDescription", iconName: "stop.fill", color: "red", duration: 1 * 60, temperature: 20),
            StagingStage(name: "stagingFixerName", description: "stagingFixerDescription", iconName: "shield.fill", color: "purple", duration: 5 * 60, temperature: 20),
            StagingStage(name: "stagingWashName", description: "stagingWashDescription", iconName: "drop", color: "cyan", duration: 10 * 60, temperature: 20)
        ]
        return ProcessPreset(name: "B&W Standard", description: "A general-purpose black & white process.", stages: stages)
    }
}
