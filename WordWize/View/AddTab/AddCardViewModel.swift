//
//  AddCardViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import Combine
import SwiftUI

class AddCardViewModel: ObservableObject {
    var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    @Published var cardText = ""
    @Published var selectedCategory = ""
    @Published var generatingCards = false
    @Published var showingFetchFailedAlert = false
    @Published var showingFetchSucceededAlert = false
    @Published var showingAddCategoryAlert = false
    @Published var showPlaceholder = true
    @Published var fetchFailedWords: [String] = []
    @Published var requestedWordCount = 1
    @Published var fetchedWordCount = 0
    @Published var addedCardCount = 0
    @Published var textFieldInput = ""
        
    private let placeHolder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"

    var displayText: String {
        showPlaceholder ? placeHolder : cardText
    }
    
    init(container: DIContainer) {
        print("init AddCardViewModel categories: \(container.appState.categories)")
        self.container = container
    }
    
    func generateCards() {
        let cancellable = generateCards()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.generatingCards = false
                print("generateCards completed failedWords: \(fetchFailedWords)")
                
                if self.fetchFailedWords.isEmpty == true {
                    self.showingFetchSucceededAlert = true
                } else {
                    self.showingFetchFailedAlert = true
                }
            }
        
        cancellable.store(in: &cancellables)

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

                let fetchPublishers = words.publisher
                    .flatMap(maxPublishers: .max(10)) { word -> AnyPublisher<Result<Card, Error>, Never> in
                        return self.fetchCard(word: word, category: self.selectedCategory)
                    }

                fetchPublishers
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        self.addedCardCount = words.count
                        self.container.persistence.saveContext()
                        self.container.coreDataService.retryFetchingImages()
                        promise(.success(()))
                    } receiveValue: { result in
                        switch result {
                        case .success(let card):
                            self.container.appState.cards.append(card)
                        case .failure(let error):
                            print("fetch definitions failed: \(error.localizedDescription)")
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchCard(word: String, category: String) -> AnyPublisher<Result<Card, Error>, Never> {
        let card = Card(context: container.persistence.viewContext)
        card.id = UUID()
        card.text = word
        card.category = category
        
        return container.networkService.fetchDefinitionsAndImages(card: card, context: container.persistence.viewContext)
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<Card, Error>, Never> in
                return Just(.failure(error)).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { output in
                self.fetchedWordCount += 1
                switch output {
                case .success(let card):
                    print("fetchCard receiveOutput success: \(card.text ?? "")")
                case .failure(let error):
                    print("fetchCard receiveOutput failure: \(error.localizedDescription)")
                    self.fetchFailedWords.append(word)
                }
                print("count: \(self.fetchedWordCount)")
            })
            .eraseToAnyPublisher()
    }
    
    func addCategory() {
        guard !textFieldInput.isEmpty,
              !container.appState.categories.contains(where: { $0.name == textFieldInput }) else { return }
        
        let category = CardCategory(context: container.persistence.viewContext)
        category.name = textFieldInput
        container.coreDataService.saveAndReload()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            selectedCategory = textFieldInput
            textFieldInput = ""
        }
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
    
    func setDefaultCategory() {
        guard let defaultCategory = container.appState.categories.first?.name,
              selectedCategory.isEmpty else { return }
        
        selectedCategory = defaultCategory
    }
}
