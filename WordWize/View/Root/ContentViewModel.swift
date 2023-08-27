//
//  ContentViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/26/23.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel
    @Published var selectedTab = TabType.study.rawValue
    @Published var showTabBar = true
    @Published var tabPoints: [CGFloat] = Array(repeating: 0, count: TabType.allCases.count)

    func onAppear() {
        dataViewModel.retryFetchingImages()
        
        guard CommandLine.arguments.contains("SETUP_DATA_FOR_TESTING") else { return }
        print("SETUP_DATA_FOR_TESTING")
        
        dataViewModel.addDefaultCategory { [weak self] in
            self?.populateRandomTestData()
        }
    }

    private func populateRandomTestData() {
        for i in 0..<Int.random(in: 1..<100) {
            let testCard = dataViewModel.makeTestCard(text: "test card \(i)")
            dataViewModel.cards.append(testCard)
            print("add card: \(i)")
        }

        dataViewModel.persistence.saveContext()
        dataViewModel.loadData()

        dataViewModel.cards.forEach { card in
            if card.category == nil {
                card.category = dataViewModel.categories.first?.name
                dataViewModel.persistence.saveContext()
            }
        }
    }
}