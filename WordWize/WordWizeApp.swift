//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI
import SwiftData

@main
struct WordWizeApp: App {
    var body: some Scene {
        let container = DIContainer(
            appState: AppState(),
            networkService: NetworkService(session: .shared))
        
        WindowGroup {
            ContentView(container: container)
                .modelContainer(for: [Card.self, CardCategory.self, Phonetic.self, Definition.self, Meaning.self, ImageData.self])
        }
    }
}

// MARK: - Global variables

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
