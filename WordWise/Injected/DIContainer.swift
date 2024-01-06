//
//  DIContainer.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine
import SwiftData

struct DIContainer {
    let networkService: NetworkServiceProtocol
    let swiftDataService: SwiftDataService
    let modelContainer: ModelContainer
    let modelContext: ModelContext
    
    @MainActor
    init(networkService: NetworkServiceProtocol) {
        let modelContainer = try! ModelContainer(for: Card.self)
        let modelContext = modelContainer.mainContext
        
        self.networkService = networkService
        self.modelContainer = modelContainer
        self.modelContext = modelContext
        
        self.swiftDataService = SwiftDataService(
            networkService: networkService,
            context: modelContext)
    }
    
    @MainActor
    static func mock(withMockCards: Bool = true) -> DIContainer {
        if withMockCards {
            MockHelper.shared.setupMockData()
        }
        
        return .init(networkService: MockNetworkService())
    }
}
