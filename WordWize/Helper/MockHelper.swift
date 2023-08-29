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
    
    func createAndSaveMockCards(persistence: Persistence, appState: AppState) {
        let cards = createMockCards(persistence: persistence)
        persistence.saveContext()
        appState.cards = cards
    }
    
    func createAndSaveMockCategory(persistence: Persistence, appState: AppState) {
        let category = CardCategory(context: persistence.viewContext)
        category.name = "Mock Category"
        persistence.saveContext()
        appState.categories.append(category)
    }
    
    func createMockCards(persistence: Persistence) -> [Card] {
        var cards = [Card]()
        
        for i in 0...100 {
            let card = Card(context: persistence.viewContext)
            card.text = "mock \(i)"
            card.setMockData(context: persistence.viewContext)
            card.masteryRate = Int16.random(in: 0...4)
            card.category = "Mock Category"
            cards.append(card)
        }
        
        return cards
    }
}
