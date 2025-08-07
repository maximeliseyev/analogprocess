import Foundation

struct StagingStage: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let color: String
    var isEnabled: Bool = true
    var duration: TimeInterval = 0
    var temperature: Double = 20.0
    
    static let defaultStages: [StagingStage] = [
        StagingStage(
            name: "Prebath",
            description: "Предварительная ванна для стабилизации температуры",
            iconName: "drop.fill",
            color: "blue"
        ),
        StagingStage(
            name: "Developer",
            description: "Проявление плёнки",
            iconName: "flask.fill",
            color: "orange"
        ),
        StagingStage(
            name: "Stop Bath",
            description: "Остановка проявления",
            iconName: "stop.fill",
            color: "red"
        ),
        StagingStage(
            name: "Fixer",
            description: "Фиксирование изображения",
            iconName: "shield.fill",
            color: "purple"
        ),
        StagingStage(
            name: "Wash",
            description: "Промывка плёнки",
            iconName: "drop",
            color: "cyan"
        ),
        StagingStage(
            name: "Stabilizer",
            description: "Стабилизация для долгосрочного хранения",
            iconName: "leaf.fill",
            color: "green"
        )
    ]
} 