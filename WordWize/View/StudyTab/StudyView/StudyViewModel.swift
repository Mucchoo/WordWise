//
//  StudyViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class StudyViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @Published var selectedCategory: String = ""
    @Published var maximumCards: Int = 1000
    @Published var showingCardView: Bool = false
    
    var studyingCards: [Card] { filterCards(for: .studying) }
    var todaysCards: [Card] { filterCards(for: .today) }
    var upcomingCards: [Card] { filterCards(for: .upcoming) }
    
    enum FilterType {
        case studying, today, upcoming
    }

    func filterCards(for type: FilterType) -> [Card] {
        return Array(dataViewModel.cards.filter { card in
            guard selectedCategory == card.category, card.rate != .oneHundred else {
                return false
            }

            switch type {
            case .studying, .today:
                return card.isTodayOrBefore
            case .upcoming:
                return card.isUpcoming
            }
        }.prefix(maximumCards))
    }

    func updateCards() {
        dataViewModel.studyingCards = studyingCards
        dataViewModel.todaysCards = todaysCards
        dataViewModel.upcomingCards = upcomingCards
    }
}
