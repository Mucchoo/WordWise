//
//  DataViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import CoreData
import SwiftUI
import Combine

class DataViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var categories: [CardCategory] = []
    @Published var cardsToStudy: [Card] = []
    @Published var cardList: [Card] = []
    @Published var requestedWordCount = 0 {
        didSet {
            print("requestedWordCount: \(requestedWordCount)")
        }
    }
    @Published var fetchedWordCount = 0 {
        didSet {
            print("fetchedWordCount: \(fetchedWordCount)")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    var fetchFailedWords: [String] = []
    var addedCardCount = 0
    let cardService: CardService
    let persistence: Persistence
    let viewContext: NSManagedObjectContext
    
    init(cardService: CardService, persistence: Persistence) {
        self.cardService = cardService
        self.persistence = persistence
        self.viewContext = persistence.viewContext
        loadData()
    }

    func loadData() {
        let cardFetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        let categoryFetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()

        do {
            let fetchedCards = try viewContext.fetch(cardFetchRequest)
            let fetchedCategories = try viewContext.fetch(categoryFetchRequest)
            DispatchQueue.main.async { [self] in
                cards = fetchedCards
                categories = fetchedCategories
                if categories.isEmpty {
                    addDefaultCategory()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateCard(id: UUID, text: String, category: String, status: Int16) {
        if let card = cards.first(where: { $0.id == id }) {
            card.text = text
            card.category = category
            card.status = status
            persistence.saveContext()
        }
    }
    
    func deleteCard(_ card: Card) {
        viewContext.delete(card)
        persistence.saveContext()
        loadData()
    }
    
    func addCategory(name: String) {
        guard !categories.contains(where: { $0.name == name }) else { return }
        
        let category = CardCategory(context: viewContext)
        category.name = name
        persistence.saveContext()
        
        DispatchQueue.main.async {
            self.categories.append(category)
        }
    }
    
    func renameCategory(before: String, after: String) {
        guard let category = categories.first(where: { $0.name == before }) else { return }
        
        DispatchQueue.main.async { [self] in
            cards.filter({ $0.category == category.name }).forEach { card in
                card.category = after
            }
            
            category.name = after
            persistence.saveContext()
            loadData()
        }
    }
    
    func deleteCategoryAndItsCards(name: String) {
        guard let category = categories.first(where: { $0.name == name }) else { return }
        viewContext.delete(category)
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", name)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print("Failed to execute batch delete: \(error)")
        }
        
        persistence.saveContext()
        
        DispatchQueue.main.async {
            self.categories.removeAll(where: { $0.name == category.name })
        }
    }
    
    func addCardPublisher(text: String, category: String) -> AnyPublisher<Void, Never> {
        fetchFailedWords = []
        
        return Deferred {
            Future<Void, Never> { promise in
                let words = text.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
                self.requestedWordCount = words.count
                self.fetchedWordCount = 0
                
                self.fetchCards(words: words, category: category)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        self.addedCardCount = words.count
                        self.persistence.saveContext()
                        self.retryFetchingImages()
                        promise(.success(()))
                    } receiveValue: { card in
                        self.cards.append(card)
                    }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCards(words: [String], category: String) -> AnyPublisher<Card, Never> {
        let fetchPublishers = words.publisher
            .buffer(size: words.count, prefetch: .keepFull, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(20)) { word -> AnyPublisher<Card, Never> in
                let card = Card(context: self.viewContext)
                card.id = UUID()
                card.text = word
                card.status = 2
                card.failedTimes = 0
                card.category = category

                let fetchCardData = self.cardService.fetchDefinitions(word: word)
                let fetchImagesData = self.cardService.fetchImages(word: word)

                return Publishers.Zip(fetchCardData, fetchImagesData)
                    .receive(on: DispatchQueue.main)
                    .tryMap { cardResponse, imageUrls in
                        print("got result of \(cardResponse.word)")
                        cardResponse.meanings?.forEach { meaning in
                            let newMeaning = Meaning(context: self.viewContext)
                            newMeaning.partOfSpeech = meaning.partOfSpeech ?? "Unknown"
                            newMeaning.createdAt = Date()
                            
                            meaning.definitions?.forEach { definition in
                                let newDefinition = Definition(context: self.viewContext)
                                newDefinition.definition = definition.definition
                                newDefinition.example = definition.example
                                newDefinition.antonyms = definition.antonyms?.joined(separator: ", ") ?? ""
                                newDefinition.synonyms = definition.synonyms?.joined(separator: ", ") ?? ""
                                newDefinition.createdAt = Date()
                                
                                newMeaning.addToDefinitions(newDefinition)
                            }
                            
                            card.addToMeanings(newMeaning)
                        }
                        
                        cardResponse.phonetics?.forEach { phonetic in
                            let newPhonetic = Phonetic(context: self.viewContext)
                            newPhonetic.audio = phonetic.audio
                            newPhonetic.text = phonetic.text
                            card.addToPhonetics(newPhonetic)
                        }

                        imageUrls.enumerated().forEach { index, url in
                            let imageUrl = ImageUrl(context: self.viewContext) // Thread 11: EXC_BAD_ACCESS (code=1, address=0xfffffffffffffff8)
                            imageUrl.urlString = url
                            imageUrl.priority = Int64(index)
                            card.addToImageUrls(imageUrl)
                        }

                        self.fetchedWordCount += 1
                        return card
                    }
                    .catch { error -> Empty<Card, Never> in
                        self.fetchFailedWords.append(word)
                        print("Failed fetching: \(word) error: \(error.localizedDescription)")
                        self.fetchedWordCount += 1
                        return Empty()
                    }
                    .eraseToAnyPublisher()
            }
            
        return fetchPublishers
            .eraseToAnyPublisher()
    }
    
    func retryFetchingImages() {
        let cardsFailedFetchingImages = cards.filter({ $0.imageUrls?.contains("error") ?? false })
        print("retryFetchingImages for: \(cardsFailedFetchingImages.count) cards")
        guard !cardsFailedFetchingImages.isEmpty else { return }
        
        let fetchPublishers = cardsFailedFetchingImages.publisher
            .buffer(size: cardsFailedFetchingImages.count, prefetch: .keepFull, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(20)) { card -> AnyPublisher<Void, Never> in
                let fetchImagesData = self.cardService.fetchImages(word: card.unwrappedText)

                return fetchImagesData
                    .receive(on: DispatchQueue.main)
                    .map { imageUrls in
                        card.imageUrls = nil
                        imageUrls.enumerated().forEach { index, url in
                            let imageUrl = ImageUrl(context: self.viewContext)
                            imageUrl.urlString = url
                            imageUrl.priority = Int64(index)
                            card.addToImageUrls(imageUrl)
                        }

                        self.fetchedWordCount += 1
                        return
                    }
                    .catch { error -> Empty<Void, Never> in
                        print("Failed retry fetching image error: \(error.localizedDescription)")
                        return Empty()
                    }
                    .eraseToAnyPublisher()
            }
            
        fetchPublishers
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.persistence.saveContext()
                self.retryFetchingImages()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    
    func resetLearningData() {
        cards.forEach { card in
            card.failedTimes = 0
            card.status = 2
        }
        persistence.saveContext()
    }
    
    func addDefaultCategory(completion: (() -> ())? = nil) {
        let fetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Category 1")

        do {
            let categories = try viewContext.fetch(fetchRequest)
            guard categories.isEmpty else { return }
            
            let newCategory = CardCategory(context: viewContext)
            newCategory.name = "Category 1"
            self.categories.append(newCategory)
            
            persistence.saveContext()
            completion?()
            
        } catch let error {
            print("Failed to fetch categories: \(error.localizedDescription)")
        }
    }
    
    func makeTestCard(text: String = "test card") -> Card {
        let card = Card(context: viewContext)
        card.text = text
        card.category = categories.first?.name
        card.id = UUID()
        return card
    }
    
    func translateDefinitions(_ card: Card, completion: (() -> ())? = nil) {
        var definitions = [String]()
        
        card.meaningsArray.forEach { meaning in
            meaning.definitionsArray.forEach { definition in
                definitions.append(definition.definition ?? "")
            }
        }
        
        cardService.fetchTranslations(definitions)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                completion?()
            } receiveValue: { response in
                print("response: \(response)")
                var index = 0
                
                card.meaningsArray.forEach { meaning in
                    meaning.definitionsArray.forEach { definition in
                        definition.translatedDefinition = response.translations[safe: index]?.text ?? ""
                        index += 1
                    }
                }
                
                self.persistence.saveContext()
            }
            .store(in: &cancellables)
    }
}
