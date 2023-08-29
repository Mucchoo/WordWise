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
        var cards = [Card]()
        
        for i in 0...100 {
            let card = Card(context: persistence.viewContext)
            card.text = "mock \(i)"
            card.setMockData(context: persistence.viewContext)
            card.masteryRate = Int16.random(in: 0...4)
            card.category = "Category 1"
            cards.append(card)
        }
        
        persistence.saveContext()
        
        DispatchQueue.main.async {
            appState.cards = cards
        }
    }
}
