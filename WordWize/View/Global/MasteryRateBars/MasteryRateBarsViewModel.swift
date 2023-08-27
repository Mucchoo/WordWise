//
//  MasteryRateBarsViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine

class MasteryRateBarsViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel
    @Published var cards: [Card] = []
    var categoryName: String
    
    var maxCount: Int {
        let counts = MasteryRate.allValues.map { rate -> Int in
            return cards.filter { $0.masteryRate == rate.rawValue }.count
        }
        
        let maxCount = counts.max() ?? 0
        return maxCount > 0 ? maxCount : 1
    }
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
    
    func updateCards(for categoryName: String) -> [Card] {
        if categoryName.isEmpty {
            return cards
        } else {
            return cards.filter({ $0.category == categoryName })
        }
    }
    
    func getCount(_ rate: MasteryRate) -> String {
        return "\(cards.filter { $0.masteryRate == rate.rawValue }.count)"
    }
    
    func updateCards() {
        if categoryName.isEmpty {
            cards = dataViewModel.cards
        } else {
            cards = dataViewModel.cards.filter({ $0.category == categoryName })
        }
    }
    
    func getRateText(_ rate: MasteryRate) -> String {
        switch rate {
        case .zero:
            return "0%"
        case .twentyFive:
            return "25%"
        case .fifty:
            return "50%"
        case .seventyFive:
            return "75%"
        case .oneHundred:
            return "100%"
        }
    }
    
    func getColors(_ rate: MasteryRate) -> [Color] {
        switch rate {
        case .zero:
            return [.black, .black, .navy]
        case .twentyFive:
            return [.black, .navy, .navy]
        case .fifty:
            return [.navy, .ocean, .ocean]
        case .seventyFive:
            return [.ocean, .ocean, .teal]
        case .oneHundred:
            return [.ocean, .teal, .teal]
        }
    }
    
    func getRatio(_ rate: MasteryRate) -> CGFloat {
        let count = cards.filter { $0.masteryRate == rate.rawValue }.count
        return CGFloat(count) / CGFloat(maxCount)
    }
}
