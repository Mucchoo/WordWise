//
//  FlashcardApp.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct FlashcardApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}
