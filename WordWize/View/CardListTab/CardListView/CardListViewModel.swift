//
//  CardListViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class CardListViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel

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
    @Published var lastCardId: UUID?

    @Published var selectMode = false {
        didSet {
            if !selectMode {
                selectedCards = []
            }
        }
    }
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
    
    func changeCategory() {
        dataViewModel.changeCategory(of: selectedCards, newCategory: pickerAlertValue)
        selectMode = false
        updateCardList()
    }
    
    func changeMasteryRate() {
        dataViewModel.changeMasteryRate(of: selectedCards, rate: selectedRate)
        selectMode = false
        updateCardList()
    }
    
    func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = card.category == categoryName
            let cardText = card.text ?? ""
            let searchTextFilter = cardText.contains(searchBarText) || searchBarText.isEmpty
            return categoryFilter && searchTextFilter
        }
        cardList = filteredCards
    }
    
    func deleteCard(_ card: Card) {
        dataViewModel.deleteCard(card)
        navigateToCardDetail = false
        updateCardList()
    }
    
    func updateCard(_ card: Card) {
        guard let cardId = card.id else { return }
        dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, rate: masteryRate)
        updateCardList()
    }
    
    func setupDetailView(_ card: Card) {
        cardId = card.id
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
        dataViewModel.deleteCards(selectedCards)
        selectMode = false
    }
}
