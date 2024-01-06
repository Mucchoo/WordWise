//
//  MockHelper.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/29/23.
//

import SwiftData
import SwiftUI

struct MockHelper {
    @Environment(\.modelContext) private var context
    static let shared = MockHelper()
    let mockCategory = "Mock Category"
    
    func setupMockData() {
        createMockCards()
        createAndSaveMockCategory()
    }
    
    private func createAndSaveMockCategory() {
        let category = CardCategory()
        category.name = mockCategory
    }
    
    private func createMockCards() {
        for i in 0..<100 {
            let card = Card()
            card.text = "mock \(i)"
            card.setCardData(CardData.mock)
            card.masteryRate = Int16.random(in: 0...4)
            card.category = mockCategory
            card.nextLearningDate = Calendar.current.date(byAdding: .day, value: Int.random(in: 0...14), to: Date()) ?? Date()
        }
    }
    
    func mockCard(rate: MasteryRate) -> Card {
        let card = Card()
        card.masteryRate = rate.rawValue
        return card
    }
}
