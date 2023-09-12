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
    @Published var showingPickerAlert = false
    @Published var showingChangeMasteryRateView = false
    @Published var showingDeleteCardsAlert = false
    @Published var cardCategory = ""
    @Published var navigateToCardDetail = false
    @Published var categoryName: String
    
    @Published var selectedCard: Card?
    @Published var selectedRate: Int16 = 0
    @Published var selectedRateString = ""

    @Published var multipleSelectionMode = false {
        didSet {
            if !multipleSelectionMode {
                selectedCards = []
            }
        }
    }
    
    init(container: DIContainer, categoryName: String) {
        self.container = container
        self.categoryName = categoryName
        
        observeChanges()
    }
    
    func changeMasteryRate() {
        var masteryRate: Int16 {
            switch selectedRateString {
            case "0%":
                return 0
            case "25%":
                return 1
            case "50%":
                return 2
            case "75%":
                return 3
            default:
                return 4
            }
        }
        
        selectedCards.forEach { card in
            card.masteryRate = masteryRate
        }
        
        container.coreDataService.saveAndReload()
        multipleSelectionMode = false
        updateCardList()
    }
    
    func updateCard() {
        guard let card = selectedCard else { return }
        print("selectedMasteryRate: \(selectedRate)")
        card.category = cardCategory
        card.masteryRate = selectedRate
        
        var nextLearningDate: Int
        switch card.masteryRate {
        case 0:
            nextLearningDate = 0
        case 1:
            nextLearningDate = 2
        case 2:
            nextLearningDate = 4
        case 3:
            nextLearningDate = 7
        default:
            nextLearningDate = 14
        }
        
        card.nextLearningDate = Calendar.current.date(byAdding: .day, value: nextLearningDate, to: Date())
        container.coreDataService.saveAndReload()
        updateCardList()
    }
    
    func showCardDetail(_ card: Card) {
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
        multipleSelectionMode = false
        updateCardList()
    }
    
    func updateCardList() {
        let filteredCards = container.appState.cards.filter { card in
            let categoryFilter = card.category == categoryName
            let cardText = card.text ?? ""
            let searchTextFilter = cardText.contains(searchBarText) || searchBarText.isEmpty
            return categoryFilter && searchTextFilter
        }
        cardList = filteredCards.sorted(by: { $0.id > $1.id } )
    }
    
    func deleteCard() {
        guard let card = selectedCard else { return }
        container.persistence.viewContext.delete(card)
        container.coreDataService.saveAndReload()
        navigateToCardDetail = false
        updateCardList()
    }
    
    func deleteSelectedCards() {
        selectedCards.forEach { card in
            container.persistence.viewContext.delete(card)
        }
        container.coreDataService.saveAndReload()
        multipleSelectionMode = false
    }
}
