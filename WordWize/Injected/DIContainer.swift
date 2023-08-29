//
//  DIContainer.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine

// Dependency Injection Container
struct DIContainer {
    let appState: AppState
    let networkService: NetworkService
    let coreDataService: CoreDataService
    let persistence: Persistence
    
    init(appState: AppState, networkService: NetworkService, persistence: Persistence) {
        self.appState = appState
        self.networkService = networkService
        self.persistence = persistence
        self.coreDataService = CoreDataService(
            persistence: persistence,
            networkService: networkService,
            appState: appState)
    }
}
