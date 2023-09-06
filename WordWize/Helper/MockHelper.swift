//
//  MockHelper.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/29/23.
//

import CoreData
import SwiftUI

struct MockHelper {
    static let shared = MockHelper()
    let mockCategory = "Mock Category"
    
    func setupMockData(persistence: Persistence, appState: AppState) {
        createAndSaveMockCards(persistence: persistence, appState: appState)
        createAndSaveMockCategory(persistence: persistence, appState: appState)
    }
    
    private func createAndSaveMockCards(persistence: Persistence, appState: AppState) {
        let cards = createMockCards(persistence: persistence)
        persistence.saveContext()
        appState.cards = cards
        updateCards(appState: appState)
    }
    
    private func createAndSaveMockCategory(persistence: Persistence, appState: AppState) {
        let category = CardCategory(context: persistence.viewContext)
        category.name = mockCategory
        persistence.saveContext()
        appState.categories.append(category)
    }
    
    private func createMockCards(persistence: Persistence) -> [Card] {
        var cards = [Card]()
        
        for i in 0..<100 {
            let card = Card(context: persistence.viewContext)
            card.text = "mock \(i)"
            card.setMockData(context: persistence.viewContext)
            card.masteryRate = Int16.random(in: 0...4)
            card.category = mockCategory
            card.nextLearningDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...14), to: Date())
            cards.append(card)
        }
        
        return cards
    }
    
    private func filterCards(for type: CardFilterType, appState: AppState) -> [Card] {
        return appState.cards.filter { card in
            switch type {
            case .studying, .today:
                return card.isTodayOrBefore
            case .upcoming:
                return card.isUpcoming
            }
        }
    }

    private func updateCards(appState: AppState) {
        appState.studyingCards = filterCards(for: .studying, appState: appState)
        appState.todaysCards = filterCards(for: .today, appState: appState)
        appState.upcomingCards = filterCards(for: .upcoming, appState: appState)
    }
}
