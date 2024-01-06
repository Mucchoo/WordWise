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
        let todaysCards = cards.filter { $0.isTodayOrBefore }
        return Array(todaysCards.prefix(maximumCards))
    }
    
    var todaysCards: [Card] {
        return cards.filter { $0.isTodayOrBefore }
    }
    
    var upcomingCards: [Card] {
        return cards.filter { $0.isUpcoming }
    }
    
    var studyButtonTitle: String {
        studyingCards.count > 0 ?
        "Study \(studyingCards.count) Cards" : "Finished Learning for Today!"
    }
    
    var categories: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: "categories") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "categories")
        }
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
