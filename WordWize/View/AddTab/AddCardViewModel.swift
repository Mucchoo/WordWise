//
//  AddCardViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import Combine
import SwiftUI

class AddCardViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @Published var cardText: String = ""
    @Published var selectedCategory: String = ""
    @Published var generatingCards: Bool = false
    @Published var showingFetchFailedAlert = false
    @Published var showingAddCategoryAlert = false
    @Published var showingFetchSucceededAlert = false
    @Published var showPlaceholder = true
    @Published var fetchFailedWords: [String] = []
    @Published var requestedWordCount = 0
    @Published var fetchedWordCount = 0
    @Published var addedCardCount = 0
        
    private let placeHolder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"

    var displayText: String {
        showPlaceholder ? placeHolder : cardText
    }
    
    func addCardPublisher() -> AnyCancellable {
        return generateCards()
            .sink { [weak self] in
                guard let self = self else { return }
                self.generatingCards = false
                
                if self.fetchFailedWords.isEmpty == true {
                    self.showingFetchSucceededAlert = true
                } else {
                    self.showingFetchFailedAlert = true
                }
            }
    }
    
    func generateCards() {
        let cancellable = addCardPublisher()
        cancellable.store(in: &dataViewModel.cancellables)

        cardText = ""
        generatingCards = true
    }
    
    private func generateCards() -> AnyPublisher<Void, Never> {
        fetchFailedWords = []
        
        return Deferred {
            Future<Void, Never> { promise in
                let words = self.cardText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
                self.requestedWordCount = words.count
                self.fetchedWordCount = 0
                
                self.fetchCards(words: words, category: self.selectedCategory)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        self.addedCardCount = words.count
                        self.dataViewModel.persistence.saveContext()
                        self.dataViewModel.retryFetchingImages()
                        promise(.success(()))
                    } receiveValue: { card in
                        self.dataViewModel.cards.append(card)
                    }
                    .store(in: &self.dataViewModel.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchCards(words: [String], category: String) -> AnyPublisher<Card, Never> {
        let fetchPublishers = words.publisher
            .flatMap(maxPublishers: .max(10)) { word -> AnyPublisher<Card, Never> in
                let card = Card(context: self.dataViewModel.viewContext)
                card.id = UUID()
                card.text = word
                card.category = category
                
                return self.dataViewModel.cardService.fetchAndPopulateCard(word: word, card: card, context: self.dataViewModel.viewContext) {
                    self.fetchedWordCount += 1
                }
                    .catch { error -> AnyPublisher<Card, Never> in
                        self.fetchFailedWords.append(word)
                        self.fetchedWordCount += 1
                        return Just(card).setFailureType(to: Never.self).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
        return fetchPublishers.eraseToAnyPublisher()
    }
    
    func addCategory(name: String) {
        if !dataViewModel.categories.contains(where: { $0.name == name }) {
            let category = CardCategory(context: dataViewModel.viewContext)
            category.name = name
            dataViewModel.persistence.saveContext()
            
            DispatchQueue.main.async {
                self.dataViewModel.categories.append(category)
            }
        }
        
        selectedCategory = name
    }
    
    func shouldDisableAddCardButton() -> Bool {
        return cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func updateTextEditor(text: String, isFocused: Bool) {
        cardText = text.lowercased()
        if cardText.isEmpty && !isFocused {
            showPlaceholder = true
        }
    }
    
    func togglePlaceHolder(_ isFocused: Bool) {
        showPlaceholder = !isFocused && (cardText.isEmpty || cardText == placeHolder)
    }
}
