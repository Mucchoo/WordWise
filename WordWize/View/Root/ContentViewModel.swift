//
//  ContentViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/26/23.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let container: DIContainer
    
    @Published var selectedTab = TabType.study.rawValue
    @Published var showTabBar = true
    @Published var tabPoints: [CGFloat] = Array(repeating: 0, count: TabType.allCases.count)
    
    init(container: DIContainer) {
        self.container = container
    }

    func onAppear() {
        container.coreDataService.retryFetchingImages()
        
        guard CommandLine.arguments.contains("SETUP_DATA_FOR_TESTING") else { return }
        print("SETUP_DATA_FOR_TESTING")
        
        container.coreDataService.addDefaultCategoryIfNeeded { [weak self] in
            self?.populateRandomTestData()
        }
    }

    private func populateRandomTestData() {
        for i in 0..<Int.random(in: 1..<100) {
            let card = Card(context: container.persistence.viewContext)
            card.text = "test card \(i)"
            card.category = container.appState.categories.first?.name
            print("add card: \(i)")
        }

        container.coreDataService.saveAndReload()

        container.appState.cards.forEach { card in
            if card.category == nil {
                card.category = container.appState.categories.first?.name
                container.persistence.saveContext()
            }
        }
    }
}
