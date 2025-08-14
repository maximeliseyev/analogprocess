import Foundation

struct StagingStage: Identifiable, Hashable {
    var id = UUID()
    var name: String
    let description: String
    let iconName: String
    let color: String
    var isEnabled: Bool = true
    var duration: TimeInterval = 0
    var temperature: Double = 20.0
    
    static let defaultStages: [StagingStage] = [
        StagingStage(
            name: "stagingPrebathName",
            description: "stagingPrebathDescription",
            iconName: "drop.fill",
            color: "blue"
        ),
        StagingStage(
            name: "stagingDevelopName",
            description: "stagingDevelopDescription",
            iconName: "flask.fill",
            color: "orange"
        ),
        StagingStage(
            name: "stagingStopBathName",
            description: "stagingStopBathDescription",
            iconName: "stop.fill",
            color: "red"
        ),
        StagingStage(
            name: "stagingBleachName",
            description: "stagingBleachDescription",
            iconName: "flask",
            color: "yellow"
        ),
        StagingStage(
            name: "stagingFixerName",
            description: "stagingFixerDescription",
            iconName: "shield.fill",
            color: "purple"
        ),
        StagingStage(
            name: "stagingWashName",
            description: "stagingWashDescription",
            iconName: "drop",
            color: "cyan"
        ),
        StagingStage(
            name: "stagingStabilizeName",
            description: "stagingStabilizeDescription",
            iconName: "leaf.fill",
            color: "green"
        )
    ]
}
