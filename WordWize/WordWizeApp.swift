//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
    @StateObject private var dataViewModel: DataViewModel = {
        let useInMemory = Self.shouldUseInMemory
        let persistence = Persistence(inMemory: useInMemory)
        let cardService: CardService = Self.isRunningForPreviews ? MockCardService() : NetworkCardService()
        return DataViewModel(cardService: cardService, persistence: persistence)
    }()
    
    private static var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    private static var shouldUseInMemory: Bool {
        isRunningForPreviews || CommandLine.arguments.contains("FOR_TESTING")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataViewModel.viewContext)
                .environmentObject(dataViewModel)
        }
    }
}
