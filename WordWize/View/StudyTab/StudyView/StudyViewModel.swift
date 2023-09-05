//
//  StudyViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

enum CardFilterType {
    case studying, today, upcoming
}

class StudyViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    @Published var selectedCategory = ""
    @Published var maximumCards = 1000
    @Published var showingCardView = false
    
    var studyButtonTitle: String {
        container.appState.studyingCards.count > 0 ?
        "Study \(container.appState.studyingCards.count) Cards" : "Finished Learning for Today!"
    }
    
    init(container: DIContainer) {
        self.container = container
        observeCards()
        observeCategories()
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
    
    private func observeCategories() {
        container.appState.$categories
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.selectedCategory = self?.container.appState.categories.first?.name ?? ""
                }
            }
            .store(in: &cancellables)
    }

    func filterCards(for type: CardFilterType) -> [Card] {
        return container.appState.cards.filter { card in
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

    func updateCards() {
        container.appState.studyingCards = Array(filterCards(for: .studying).prefix(maximumCards))
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
