//
//  VocabBuilderApp.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct VocabBuilderApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var dataViewModel = DataViewModel(context: PersistenceController.shared.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(dataViewModel)
        }
    }
}
