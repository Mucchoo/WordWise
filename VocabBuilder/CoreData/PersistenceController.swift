//
//  PersistenceController.swift
//  VocabBuilder
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
        
        for i in 0..<100 {
            let newCard = Card(context: viewContext)
            newCard.status = Int16(i % 3)
            newCard.failedTimes = 0
            newCard.text = "Test\(i)"
        }
        
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
                fatalError("Unresolved error \(error.localizedDescription), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription), \(error as NSError).userInfo")
            }
        }
    }
    
    func addDefaultCategory() {
        let fetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Category 1")

        do {
            let categories = try viewContext.fetch(fetchRequest)
            if categories.isEmpty {
                let newCategory = CardCategory(context: viewContext)
                newCategory.name = "Category 1"
                PersistenceController.shared.saveContext()
            }
        } catch let error {
            print("Failed to fetch categories: \(error.localizedDescription)")
        }
    }
}
