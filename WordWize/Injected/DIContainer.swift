//
//  DIContainer.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine
import CoreData

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
    
    static func mock(withMockCards: Bool = true) -> DIContainer {
        let mockAppState = AppState()
        let mockPersistence = Persistence(isMock: true)
        
        if withMockCards {
            mockAppState.isDataLoaded = true
            MockHelper.shared.createAndSaveMockCards(persistence: mockPersistence, appState: mockAppState)
            MockHelper.shared.createAndSaveMockCategory(persistence: mockPersistence, appState: mockAppState)
        }
        
        return .init(appState: mockAppState, networkService: MockNetworkService(), persistence: mockPersistence)
    }
}
