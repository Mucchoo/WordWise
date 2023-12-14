//
//  DIContainer.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine
import SwiftData

struct DIContainer {
    let appState: AppState
    let networkService: NetworkService
    let swiftDataService: SwiftDataService
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @MainActor
    init(appState: AppState, urlSession: URLSession) {
        let modelContainer = try! ModelContainer(for: Card.self, CardCategory.self)
        let modelContext = modelContainer.mainContext
        
        self.appState = appState
        self.networkService = .init(session: urlSession, context: modelContext)
        self.modelContainer = modelContainer
        self.modelContext = modelContext
        
        self.swiftDataService = SwiftDataService(
            networkService: networkService,
            appState: appState,
            context: modelContext)
    }
    
    @MainActor
    static func mock(withMockCards: Bool = true) -> DIContainer {
        let mockAppState = AppState()
        
        if withMockCards {
            MockHelper.shared.setupMockData(appState: mockAppState)
        }
        
        return .init(appState: mockAppState, urlSession: .mock)
    }
}
