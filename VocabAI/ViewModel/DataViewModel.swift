//
//  DataViewModel.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/2/23.
//

import CoreData
import SwiftUI
import Combine

protocol CardService {
    func fetch(word: String) -> AnyPublisher<CardResponse, Error>
    func fetchImages(word: String) -> AnyPublisher<[String], Error>
}

protocol Persistence {
    var viewContext: NSManagedObjectContext { get }
    func saveContext()
}

class DataViewModel: ObservableObject {
    var cardService: CardService
    var persistence: Persistence
    @Published var cards: [Card] = []
    @Published var categories: [CardCategory] = []
    @Published var cardsToStudy: [Card] = []
    @Published var cardList: [Card] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    var maxStatusCount: Int {
        let statuses = [0, 1, 2]
        let counts = statuses.map { status -> Int in
            return cards.filter { $0.status == Int16(status) }.count
        }
        return counts.max() ?? 0
    }
    
    init(cardService: CardService, persistence: Persistence) {
        self.cardService = cardService
        self.persistence = persistence
        loadData()
    }

    func loadData() {
        print("loadData")
        let cardFetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        let categoryFetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()

        do {
            let fetchedCards = try persistence.viewContext.fetch(cardFetchRequest)
            let fetchedCategories = try persistence.viewContext.fetch(categoryFetchRequest)
            DispatchQueue.main.async {
                self.cards = fetchedCards
                self.categories = fetchedCategories
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func updateCard(id: UUID, text: String, category: String, status: Int16, failedTimesIndex: Int) {
        print("updateCard id: \(id) text: \(text) category: \(category) status: \(status) failedTimesIndex: \(failedTimesIndex)")
        if let card = cards.first(where: { $0.id == id }) {
            card.text = text
            card.category = category
            card.status = status
            card.failedTimes = Int64(Global.failedTimeOptions[failedTimesIndex])
            PersistenceController.shared.saveContext()
        }
    }
    
    func deleteCard(_ card: Card) {
        persistence.viewContext.delete(card)
        PersistenceController.shared.saveContext()
        loadData()
    }
    
    func addCategory(name: String) {
        let category = CardCategory(context: persistence.viewContext)
        category.name = name
        PersistenceController.shared.saveContext()
        
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
            PersistenceController.shared.saveContext()
        }
    }
    
    func deleteCategory(name: String) {
        guard let category = categories.first(where: { $0.name == name }) else { return }
        persistence.viewContext.delete(category)
        PersistenceController.shared.saveContext()
        
        DispatchQueue.main.async {
            self.categories.removeAll(where: { $0.name == category.name })
        }
    }
    
    func addCardPublisher(text: String, category: String) -> AnyPublisher<[String], Never> {
        return Deferred {
            Future<[String], Never> { promise in
                var fetchFailedWords: [String] = []
                
                let words = text.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
                let fetchCard = self.fetchCards(words: words, category: category)
                
                fetchCard
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .failure(let error):
                            print("Failed fetching: \(error.localizedDescription)")
                            fetchFailedWords.append(error.localizedDescription)  // Handle errors here
                        case .finished:
                            promise(.success(fetchFailedWords))
                        }
                    } receiveValue: { card in
                        self.cards.append(card)
                        PersistenceController.shared.saveContext()
                    }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCards(words: [String], category: String) -> AnyPublisher<Card, Error> {
        let fetchPublishers = words.map { word -> AnyPublisher<Card, Error> in
            let card = Card(context: persistence.viewContext)
            card.id = UUID()
            card.text = word
            card.status = 2
            card.failedTimes = 0
            card.category = category

            let fetchCardData = cardService.fetch(word: word)
            let fetchImagesData = cardService.fetchImages(word: word)

            return Publishers.Zip(fetchCardData, fetchImagesData)
                .tryMap { cardResponse, imageUrls in
                    cardResponse.meanings?.forEach { meaning in
                        let newMeaning = Meaning(context: self.persistence.viewContext)
                        newMeaning.partOfSpeech = meaning.partOfSpeech ?? "Unknown"
                        
                        meaning.definitions?.forEach { definition in
                            let newDefinition = Definition(context: self.persistence.viewContext)
                            newDefinition.definition = definition.definition
                            newDefinition.example = definition.example
                            newDefinition.antonyms = definition.antonyms?.joined(separator: ", ") ?? ""
                            newDefinition.synonyms = definition.synonyms?.joined(separator: ", ") ?? ""
                            
                            newMeaning.addToDefinitions(newDefinition)
                        }
                        
                        card.addToMeanings(newMeaning)
                    }
                    
                    cardResponse.phonetics?.forEach { phonetic in
                        let newPhonetic = Phonetic(context: self.persistence.viewContext)
                        newPhonetic.audio = phonetic.audio
                        newPhonetic.text = phonetic.text
                        card.addToPhonetics(newPhonetic)
                    }

                    imageUrls.enumerated().forEach { index, url in
                        let imageUrl = ImageUrl(context: self.persistence.viewContext)
                        imageUrl.urlString = url
                        imageUrl.priority = Int64(index)
                        card.addToImageUrls(imageUrl)
                    }

                    return card
                }
                .eraseToAnyPublisher()
        }

        return Publishers.MergeMany(fetchPublishers)
            .collect()
            .flatMap { $0.publisher }
            .eraseToAnyPublisher()
    }

    func resetLearningData() {
        cards.forEach { card in
            card.failedTimes = 0
            card.status = 2
        }
        PersistenceController.shared.saveContext()
    }
}
