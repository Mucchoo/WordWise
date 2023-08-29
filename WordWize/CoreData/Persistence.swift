//
//  Persistence.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/20/23.
//

import CoreData
import CloudKit

class Persistence: ObservableObject {
    let container: NSPersistentCloudKitContainer

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    init(isMock: Bool) {
        container = NSPersistentCloudKitContainer(name: "Card")

        if isMock {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error.localizedDescription), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDataChange(notification:)), name: .NSPersistentStoreRemoteChange, object: nil)
    }

    @objc func handleDataChange(notification: Notification) {
        DispatchQueue.main.async {
            self.objectWillChange.send()
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

