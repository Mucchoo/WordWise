//
//  StudyViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class StudyViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    @Published var selectedCategory = ""
    @Published var maximumCards = 1000
    @Published var showingCardView = false
    
    enum FilterType {
        case studying, today, upcoming
    }
    
    var studyButtonTitle: String {
        container.appState.studyingCards.count > 0 ?
        "Study \(container.appState.studyingCards.count) Cards" : "Finished Learning for Today!"
    }
    
    init(container: DIContainer) {
        self.container = container
        observeCards()
        
        DispatchQueue.main.async {
            self.selectedCategory = container.appState.categories.first?.name ?? ""
        }
    }
    
    private func observeCards() {
        container.appState.$cards
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateCards()
                }
            }
            .store(in: &cancellables)
    }

    func filterCards(for type: FilterType) -> [Card] {
        return Array(container.appState.cards.filter { card in
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
        container.appState.studyingCards = filterCards(for: .studying)
        container.appState.todaysCards = filterCards(for: .today)
        container.appState.upcomingCards = filterCards(for: .upcoming)
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
        let categoryCards = container.appState.cards.filter { $0.category == selectedCategory }
        let rateCards = categoryCards.filter { $0.rate == rate }
        return rateCards.count
    }
}
