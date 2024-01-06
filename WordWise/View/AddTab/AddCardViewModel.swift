//
//  AddCardViewModel.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/27/23.
//

import Combine
import SwiftUI
import SwiftData

class AddCardViewModel: ObservableObject {
    
    enum AlertType {
        case addCategory
        case fetchFailed
        case fetchSucceeded
    }
    
    var cancellables = Set<AnyCancellable>()
    let container: DIContainer
    
    var cards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        return (try? container.modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    var categories: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: "categories") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "categories")
        }
    }
    
    @Published var cardText = ""
    @Published var selectedCategory = ""
    @Published var generatingCards = false
    @Published var showPlaceholder = true
    @Published var fetchFailedTexts: [String] = []
    @Published var requestedWordCount = 1
    @Published var fetchedWordCount = 0
    @Published var addedCardCount = 0
    @Published var textFieldInput = ""
    @Published var showingAlert = false
    @Published var currentAlert: AlertType? {
        didSet {
            showingAlert = true
        }
    }
        
    let placeHolder = "pineapple\nstrawberry\ncherry\nblueberry\npeach"

    var displayText: String {
        showPlaceholder ? placeHolder : cardText
    }
    
    var alertTitle: String {
        switch currentAlert {
        case .addCategory:
            return "Add Category"
        case .fetchFailed:
            return "Failed to add cards"
        default:
            return "Added Cards"
        }
    }
    
    var alertMessage: String {
        switch currentAlert {
        case .addCategory:
            return "Please enter the new category name."
        case .fetchFailed:
            return "Failed to find these wards on the dictionary.\n\n\(fetchFailedTexts.joined(separator: "\n"))"
        default:
            return "Added \(addedCardCount) cards successfully."
        }
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    @MainActor
    func generateCards() {
        let cancellable = generateCards()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.generatingCards = false
                self?.currentAlert = self?.fetchFailedTexts.isEmpty == true ? .fetchSucceeded : .fetchFailed
            }
        
        cancellable.store(in: &cancellables)

        cardText = ""
        generatingCards = true
    }
    
    @MainActor
    private func generateCards() -> AnyPublisher<Void, Never> {
        fetchFailedTexts = []
        return Deferred {
            Future<Void, Never> { promise in
                let texts = self.cardText.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
                self.requestedWordCount = texts.count
                self.fetchedWordCount = 0

                let fetchPublishers = texts.publisher
                    .flatMap(maxPublishers: .max(5)) { text -> AnyPublisher<Result<CardData, Error>, Never> in
                        return self.fetchTextDefinition(text: text)
                    }

                fetchPublishers
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        self.addedCardCount = texts.count
                        self.container.swiftDataService.retryFetchingImagesIfNeeded()
                        promise(.success(()))
                    } receiveValue: { result in
                        switch result {
                        case .success(let cardData):
                            let card = Card()
                            card.setCardData(cardData)
                            card.category = self.selectedCategory
                            card.nextLearningDate = Date()
                        case .failure(let error):
                            print("fetch definitions failed: \(error.localizedDescription)")
                        }
                    }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor
    private func fetchTextDefinition(text: String) -> AnyPublisher<Result<CardData, Error>, Never> {
        
        return container.networkService.fetchDefinitionsAndImages(text: text)
            .map { .success($0) }
            .catch { error -> AnyPublisher<Result<CardData, Error>, Never> in
                print("catch error:\(error.localizedDescription)")
                return Just(.failure(error)).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { output in
                print("handleEvents output:\(output)")
                self.fetchedWordCount += 1
                switch output {
                case .success(let card):
                    print("fetchCard receiveOutput success: \(card.text)")
                case .failure(let error):
                    print("fetchCard receiveOutput failure: \(error.localizedDescription)")
                    self.fetchFailedTexts.append(text)
                }
                print("fetchCard fetchedWordCount: \(self.fetchedWordCount)")
            })
            .eraseToAnyPublisher()
    }
    
    func addCategory() {
        guard !textFieldInput.isEmpty,
              !categories.contains(where: { $0 == textFieldInput }) else { return }
        
        categories.append(textFieldInput)
        
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
        guard let defaultCategory = categories.first, selectedCategory.isEmpty else { return }
        selectedCategory = defaultCategory
    }
}
