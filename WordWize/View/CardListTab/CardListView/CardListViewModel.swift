//
//  CardListViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class CardListViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    let container: DIContainer

    @Published var cardList: [Card] = []
    @Published var selectedCards: [Card] = []
    @Published var searchBarText = ""
    @Published var pickerAlertValue = ""
    @Published var selectedRate = ""
    @Published var showingPickerAlert = false
    @Published var showingChangeMasteryRateView = false
    @Published var showingDeleteCardsAlert = false
    @Published var cardText = ""
    @Published var cardId: UUID?
    @Published var masteryRate: Int16 = 0
    @Published var cardCategory = ""
    @Published var navigateToCardDetail = false
    @Published var categoryName: String

    @Published var selectMode = false {
        didSet {
            if !selectMode {
                selectedCards = []
            }
        }
    }
    
    init(container: DIContainer, categoryName: String) {
        self.container = container
        self.categoryName = categoryName
        
        observeChanges()
    }
    
    private func observeChanges() {
        container.appState.$cards
            .sink { [weak self] _ in
                self?.updateCardList()
            }
            .store(in: &cancellables)

        $searchBarText
            .sink { [weak self] _ in
                self?.updateCardList()
            }
            .store(in: &cancellables)
    }
    
    func changeCategory() {
        selectedCards.forEach { card in
            card.category = pickerAlertValue
        }
        container.coreDataService.saveAndReload()
        selectMode = false
        updateCardList()
    }
    
    func changeMasteryRate() {
        var masteryRate: Int16 = 0
        switch selectedRate {
        case "25%":
            masteryRate = 1
        case "50%":
            masteryRate = 2
        case "75%":
            masteryRate = 3
        case "100%":
            masteryRate = 4
        default:
            return
        }
        
        selectedCards.forEach { card in
            card.masteryRate = masteryRate
        }
        
        container.coreDataService.saveAndReload()
        selectMode = false
        updateCardList()
    }
    
    func updateCardList() {
        let filteredCards = container.appState.cards.filter { card in
            let categoryFilter = card.category == categoryName
            let cardText = card.text ?? ""
            let searchTextFilter = cardText.contains(searchBarText) || searchBarText.isEmpty
            return categoryFilter && searchTextFilter
        }
        cardList = filteredCards
    }
    
    func deleteCard(_ card: Card) {
        container.persistence.viewContext.delete(card)
        container.coreDataService.saveAndReload()
        navigateToCardDetail = false
        updateCardList()
    }
    
    func updateCard(_ card: Card) {
        card.text = cardText
        card.category = cardCategory
        card.masteryRate = masteryRate
        
        var nextLearningDate: Int
        switch card.masteryRate {
        case 0:
            nextLearningDate = 1
        case 1:
            nextLearningDate = 2
        case 2:
            nextLearningDate = 4
        case 3:
            nextLearningDate = 7
        case 4:
            nextLearningDate = 14
        default:
            return
        }
        
        card.nextLearningDate = Calendar.current.date(byAdding: .day, value: nextLearningDate, to: Date())
        card.masteryRate += 1
        
        container.coreDataService.saveAndReload()
        updateCardList()
    }
    
    func setupDetailView(_ card: Card) {
        cardText = card.text ?? ""
        cardCategory = card.category ?? ""
        navigateToCardDetail = true
    }
    
    func selectCard(_ card: Card) {
        if !selectedCards.contains(where: { $0 == card }) {
            selectedCards.append(card)
        } else {
            selectedCards.removeAll(where: { $0 == card })
        }
    }
    
    func deleteSelectedCards() {
        selectedCards.forEach { card in
            container.persistence.viewContext.delete(card)
        }
        container.coreDataService.saveAndReload()
        selectMode = false
    }
}
