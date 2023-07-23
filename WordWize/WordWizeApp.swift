//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
    let persistence: persistence
    let cardService: CardService
    @StateObject var dataViewModel: DataViewModel

    init() {
        persistence = .init(inMemory: CommandLine.arguments.contains("FOR_TESTING"))
        
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
