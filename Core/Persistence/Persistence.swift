//
//  Persistence.swift
//  Film claculator
//
//  Created by Maxim Eliseyev on 11.07.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем тестовые данные для превью
        let film = Film(context: viewContext)
        film.id = "test-film"
        film.name = "Ilford HP5+"
        film.manufacturer = "Ilford"
        film.type = "Black & White"
        film.desc = "Классическая черно-белая пленка"
        film.defaultISO = 400
        
        let developer = Developer(context: viewContext)
        developer.id = "test-developer"
        developer.name = "Kodak D-76"
        developer.manufacturer = "Kodak"
        developer.type = "powder"
        developer.desc = "Классический порошковый проявитель"
        developer.defaultDilution = "1+1"
        
        let developmentTime = DevelopmentTime(context: viewContext)
        developmentTime.dilution = "1+1"
        developmentTime.iso = 400
        developmentTime.time = 540
        developmentTime.film = film
        developmentTime.developer = developer
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FilmСlaculator")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
