//
//  WordWiseApp.swift
//  WordWise
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI
import SwiftData

@main
struct WordWiseApp: App {
    var body: some Scene {
        let container = DIContainer(urlSession: .shared)
        
        WindowGroup {
            ContentView(container: container)
                .modelContainer(container.modelContainer)
        }
    }
}

// MARK: - Global variables

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
