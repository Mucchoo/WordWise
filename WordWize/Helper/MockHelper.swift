//
//  MockHelper.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/29/23.
//

import SwiftData
import SwiftUI

struct MockHelper {
    static let shared = MockHelper()
    let mockCategory = "Mock Category"
    
    func setupMockData(context: ModelContext, appState: AppState) {
        createAndSaveMockCards(context: context, appState: appState)
        createAndSaveMockCategory(context: context, appState: appState)
    }
    
    private func createAndSaveMockCards(context: ModelContext, appState: AppState) {
        let cards = createMockCards(context: context)
        appState.cards = cards
        updateCards(appState: appState)
    }
    
    private func createAndSaveMockCategory(context: ModelContext, appState: AppState) {
        let category = CardCategory()
        category.name = mockCategory
        appState.categories.append(category)
    }
    
    private func createMockCards(context: ModelContext) -> [Card] {
        var cards = [Card]()
        
        for i in 0..<100 {
            let card = Card()
            card.text = "mock \(i)"
            card.setMockData(context: context)
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
    
    func mockCard(rate: MasteryRate, context: ModelContext) -> Card {
        let card = Card()
        card.masteryRate = rate.rawValue
        return card
    }
}
