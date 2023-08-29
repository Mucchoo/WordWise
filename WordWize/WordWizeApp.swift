//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
//    private static var isRunningForPreviews: Bool {
//        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
//    }
//
//    private static var shouldUseInMemory: Bool {
//        isRunningForPreviews || CommandLine.arguments.contains("FOR_TESTING")
//    }

    var body: some Scene {
        let container = DIContainer(
            appState: AppState(),
            networkService: RealNetworkService(),
            persistence: Persistence(isMock: false))
        
        WindowGroup {
            ContentView(container: container)
        }
    }
}
