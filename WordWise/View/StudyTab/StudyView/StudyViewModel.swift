//
//  StudyViewModel.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine
import SwiftData

enum CardFilterType {
    case studying, today, upcoming
}

class StudyViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    @Published var selectedCategory = ""
    @Published var maximumCards = 1000
    @Published var showingCardView = false
    
    var cards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        return (try? container.modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    var studyingCards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.isTodayOrBefore })
        let todaysCards = (try? container.modelContext.fetch(fetchDescriptor)) ?? []
        return Array(todaysCards.prefix(maximumCards))
    }
    
    var studyButtonTitle: String {
        studyingCards.count > 0 ?
        "Study \(studyingCards.count) Cards" : "Finished Learning for Today!"
    }
    
    
    init(container: DIContainer) {
        self.container = container
    }

    func filterCards(for type: CardFilterType) -> [Card] {
        return cards.filter { card in
            guard selectedCategory == card.category, card.rate != .oneHundred else {
                return false
            }

            switch type {
            case .studying, .today:
                return card.isTodayOrBefore
            case .upcoming:
                return card.isUpcoming
            }
        }
    }
    
    func getRateBarColors(rate: MasteryRate) -> [Color] {
        switch rate {
        case .zero:
            return [.black, .navy]
        case .twentyFive:
            return [.navy, .ocean]
        case .fifty:
            return [.navy, .ocean]
        case .seventyFive:
            return [.ocean, .sky]
        case .oneHundred:
            return []
        }
    }
    
    func rateBarCardCount(rate: MasteryRate) -> Int {
        let categoryCards = cards.filter { $0.category == selectedCategory }
        let rateCards = categoryCards.filter { $0.rate == rate }
        return rateCards.count
    }
}
