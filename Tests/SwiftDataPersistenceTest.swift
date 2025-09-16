import SwiftData
import SwiftUI

// Простая тестовая версия для диагностики
struct SwiftDataPersistenceTest {
    static let shared = SwiftDataPersistenceTest()

    let modelContainer: ModelContainer

    init() {
        print("🧪 Testing basic SwiftData setup...")

        do {
            // Начнем с минимальной схемы
            let testSchema = Schema([
                SwiftDataFilm.self,
                SwiftDataDeveloper.self
            ])

            let config = ModelConfiguration(
                schema: testSchema,
                isStoredInMemoryOnly: true  // Начнем с in-memory
            )

            modelContainer = try ModelContainer(for: testSchema, configurations: [config])
            print("✅ Basic SwiftData test successful")

        } catch {
            print("❌ Basic SwiftData test failed: \(error)")
            // Создаем пустой контейнер для предотвращения краша
            let emptySchema = Schema([SwiftDataFilm.self])
            let emptyConfig = ModelConfiguration(schema: emptySchema, isStoredInMemoryOnly: true)
            modelContainer = try! ModelContainer(for: emptySchema, configurations: [emptyConfig])
        }
    }
}