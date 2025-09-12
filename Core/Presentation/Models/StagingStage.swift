import Foundation
import SwiftUI

enum StageType: String, Codable {
    case prebath
    case develop
    case stopBath
    case bleach
    case fixer
    case wash
    case stabilize
    case unknown
}

struct StagingStage: Identifiable, Hashable {
    var id = UUID()
    var name: String
    let description: String
    let iconName: String
    let color: String
    var isEnabled: Bool = true
    var duration: TimeInterval = 0
    var temperature: Int = 20
    // Store selected agitation preset as localization key to avoid cross-feature dependency
    var agitationPresetKey: String? = nil
    
    var type: StageType {
        switch name {
        case "stagingDevelopName": return .develop
        case "stagingFixerName": return .fixer
        case "stagingBleachName": return .bleach
        case "stagingStopBathName": return .stopBath
        case "stagingPrebathName": return .prebath
        case "stagingWashName": return .wash
        case "stagingStabilizeName": return .stabilize
        default: return .unknown
        }
    }
    
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
