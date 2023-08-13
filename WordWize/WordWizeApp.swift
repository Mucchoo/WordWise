//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
    private var persistence: Persistence
    private var cardService: CardService
    
    @StateObject private var dataViewModel: DataViewModel = {
        let useInMemory = Self.shouldUseInMemory
        let persistence = Persistence(inMemory: useInMemory)
        let cardService = NetworkCardService()
        return DataViewModel(cardService: cardService, persistence: persistence)
    }()
    
    private static var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private static var shouldUseInMemory: Bool {
        isRunningForPreviews || CommandLine.arguments.contains("FOR_TESTING")
    }

    init() {
        let useInMemory = Self.shouldUseInMemory
        self.persistence = .init(inMemory: useInMemory)
        self.cardService = NetworkCardService()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .environmentObject(dataViewModel)
        }
    }
}
