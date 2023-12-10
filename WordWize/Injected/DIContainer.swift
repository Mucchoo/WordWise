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
    
    init(appState: AppState, networkService: NetworkService) {
        self.appState = appState
        self.networkService = networkService
        self.swiftDataService = SwiftDataService(
            networkService: networkService,
            appState: appState)
    }
    
    @MainActor
    static func mock(withMockCards: Bool = true) -> DIContainer {
        let mockAppState = AppState()
        let schema = Schema([Card.self, CardCategory.self, Phonetic.self, Definition.self, Meaning.self, ImageData.self])
        
        if withMockCards {
            MockHelper.shared.setupMockData(appState: mockAppState)
        }
        
        return .init(
            appState: mockAppState,
            networkService: NetworkService(session: .mock))
    }
}
