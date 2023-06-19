//
//  PersistenceController.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/20/23.
//

import CoreData

struct PersistenceController {
    let container: NSPersistentContainer
    
    static let shared = PersistenceController()
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newCard = Card(context: viewContext)
        newCard.status = 2
        newCard.failedTimes = 0
        newCard.text = "Test"
        
        shared.saveContext()
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Card")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
