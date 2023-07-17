//
//  persistence.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/20/23.
//

import CoreData

class persistence: ObservableObject {
    let container: NSPersistentContainer
        
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    static var preview: persistence = {
        let result = persistence(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<100 {
            let newCard = Card(context: viewContext)
            newCard.status = Int16(i % 3)
            newCard.failedTimes = 0
            newCard.text = "Test\(i)"
        }
    
        result.saveContext()
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
}
