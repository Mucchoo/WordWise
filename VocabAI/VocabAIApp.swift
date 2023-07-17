//
//  VocabAIApp.swift
//  VocabAI
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct VocabAIApp: App {
    let persistence: persistence
    let cardService: CardService
    @StateObject var dataViewModel: DataViewModel

    init() {
        let forTesting = CommandLine.arguments.contains("FOR_TESTING")
        persistence = .init(inMemory: forTesting)
        
        self.cardService = NetworkCardService()
        let dataViewModel = DataViewModel(cardService: cardService, persistence: persistence)
        self._dataViewModel = StateObject(wrappedValue: dataViewModel)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .environmentObject(dataViewModel)
        }
    }
}
