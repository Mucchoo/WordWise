//
//  VocabAIApp.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct VocabAIApp: App {
    let persistenceController = PersistenceController.shared
    let cardService: CardService
    @StateObject var dataViewModel: DataViewModel

    init() {
        self.cardService = NetworkCardService()
        let dataViewModel = DataViewModel(cardService: cardService, persistence: persistenceController)
        self._dataViewModel = StateObject(wrappedValue: dataViewModel)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(dataViewModel)
        }
    }
}
