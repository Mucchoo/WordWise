//
//  MockHelper.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/29/23.
//

import SwiftData
import SwiftUI

struct MockHelper {
    @Environment(\.modelContext) private var context
    static let shared = MockHelper()
    let mockCategory = "Mock Category"
    
    func setupMockData(appState: AppState) {
        createAndSaveMockCards(appState: appState)
        createAndSaveMockCategory(appState: appState)
    }
    
    private func createAndSaveMockCards(appState: AppState) {
        let cards = createMockCards()
        appState.cards = cards
        updateCards(appState: appState)
    }
    
    private func createAndSaveMockCategory(appState: AppState) {
        let category = CardCategory()
        category.name = mockCategory
        appState.categories.append(category)
    }
    
    private func createMockCards() -> [Card] {
        var cards = [Card]()
        
        for i in 0..<100 {
            let card = Card()
            card.text = "mock \(i)"
            card.setMockData()
            card.masteryRate = Int16.random(in: 0...4)
            card.category = mockCategory
            card.nextLearningDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...14), to: Date()) ?? Date()
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
    
    func mockCard(rate: MasteryRate) -> Card {
        let card = Card()
        card.masteryRate = rate.rawValue
        return card
    }
}
