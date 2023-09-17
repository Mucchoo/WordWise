//
//  WordWizeApp.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

@main
struct WordWizeApp: App {
    
    init() {
        loadEnvironmentVariables()
    }
    
    var body: some Scene {
        let container = DIContainer(
            appState: AppState(),
            networkService: NetworkService(session: .shared),
            persistence: Persistence(isMock: false))
        
        WindowGroup {
            ContentView(container: container)
        }
    }
    
    private func loadEnvironmentVariables() {
        guard let envPath = Bundle.main.path(forResource: "Keys.env", ofType: nil),
              let contents = try? String(contentsOfFile: envPath) else { return }
        
        let lines = contents.split(separator: "\n")
        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            
            let key = String(parts[0])
            let value = String(parts[1])
            print("Setting \(key) to \(value)")
            setenv(key, value, 1)
        }
    }
}

// MARK: - Global variables

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
