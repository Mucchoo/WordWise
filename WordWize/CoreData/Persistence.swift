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

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Card")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error.localizedDescription), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        setupCloudKitSubscription()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDataChange(notification:)), name: .NSPersistentStoreRemoteChange, object: nil)
    }

    private func setupCloudKitSubscription() {
        let subscription = CKDatabaseSubscription(subscriptionID: "all-data-changed")
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo

        let privateDatabase = CKContainer.default().privateCloudDatabase
        privateDatabase.save(subscription) { (result, error) in
            if let error = error {
                print("Failed to set up CloudKit subscription: \(error.localizedDescription)")
            }
        }
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

