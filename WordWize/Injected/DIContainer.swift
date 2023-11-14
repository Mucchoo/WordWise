//
//  DIContainer.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine
import SwiftData

// Dependency Injection Container
struct DIContainer {
    let appState: AppState
    let networkService: NetworkService
    let swiftDataService: SwiftDataService
    let context: ModelContext
    
    init(appState: AppState, networkService: NetworkService, context: ModelContext) {
        self.appState = appState
        self.networkService = networkService
        self.context = context
        self.swiftDataService = SwiftDataService(
            context: context,
            networkService: networkService,
            appState: appState)
    }
    
    @MainActor
    static func mock(withMockCards: Bool = true) -> DIContainer {
        let mockAppState = AppState()
        let schema = Schema([Card.self, CardCategory.self, Phonetic.self, Definition.self, Meaning.self, ImageData.self])
        let modelContainer = try! ModelContainer(for: schema, configurations: .init(isStoredInMemoryOnly: true))
        let mockcontext = modelContainer.mainContext
        
        if withMockCards {
            mockAppState.isDataLoaded = true
            MockHelper.shared.setupMockData(context: mockcontext, appState: mockAppState)
        }
        
        return .init(
            appState: mockAppState,
            networkService: NetworkService(session: .mock),
            context: mockcontext)
    }
}
