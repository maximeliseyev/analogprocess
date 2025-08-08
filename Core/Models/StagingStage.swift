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
            name: "Prebath",
            description: "Предварительная ванна для стабилизации температуры",
            iconName: "drop.fill",
            color: "blue"
        ),
        StagingStage(
            name: "Develop",
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
            name: "Bleach",
            description: "Отбелка",
            iconName: "flask",
            color: "yellow"
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
            name: "Stabilize",
            description: "Стабилизация для долгосрочного хранения",
            iconName: "leaf.fill",
            color: "green"
        )
    ]
} 
