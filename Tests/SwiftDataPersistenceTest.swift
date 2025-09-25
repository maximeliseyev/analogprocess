import SwiftData
import SwiftUI

// Простая тестовая версия для диагностики
struct SwiftDataPersistenceTest {
    static let shared = SwiftDataPersistenceTest()

    let modelContainer: ModelContainer

    init() {
        print("🧪 Testing basic SwiftData setup...")

        do {
            // Используем унифицированную тестовую конфигурацию
            let (schema, config) = SwiftDataConfigurationManager.createTestConfiguration()
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            print("✅ Unified test configuration successful")
            print("📋 Test schema entities: \(SwiftDataSchemas.entityNames(for: schema))")

        } catch {
            print("❌ Unified test configuration failed: \(error)")
            // Fallback к самой простой схеме
            let emptySchema = Schema([SwiftDataFilm.self])
            let emptyConfig = ModelConfiguration(schema: emptySchema, isStoredInMemoryOnly: true)
            do {
                modelContainer = try ModelContainer(for: emptySchema, configurations: [emptyConfig])
                print("⚠️ Using fallback test schema")
            } catch {
                fatalError("Failed to create even basic test container: \(error)")
            }
        }
    }
}