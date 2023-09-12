//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
    var body: some Scene {
        let container = DIContainer(
            appState: AppState(),
            networkService: NetworkService(session: .shared),
            persistence: Persistence(isMock: false))
        
        WindowGroup {
            ContentView(container: container)
        }
    }
}

// MARK: - Global variables

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
