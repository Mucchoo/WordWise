//
//  DataViewModel.swift
//  WordWize
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

class DataViewModel: ObservableObject {
    let cardService: CardService
    let persistence: persistence
    let viewContext: NSManagedObjectContext
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
    
    init(cardService: CardService, persistence: persistence) {
        self.cardService = cardService
        self.persistence = persistence
        self.viewContext = persistence.viewContext
        loadData()
    }

    func loadData() {
        print("loadData")
        let cardFetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        let categoryFetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()

        do {
            let fetchedCards = try viewContext.fetch(cardFetchRequest)
            let fetchedCategories = try viewContext.fetch(categoryFetchRequest)
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
            persistence.saveContext()
        }
    }
    
    func deleteCard(_ card: Card) {
        viewContext.delete(card)
        persistence.saveContext()
        loadData()
    }
    
    func addCategory(name: String) {
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
        }
    }
    
    func deleteCategory(name: String) {
        guard let category = categories.first(where: { $0.name == name }) else { return }
        viewContext.delete(category)
        persistence.saveContext()
        
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
                        self.persistence.saveContext()
                    }
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchCards(words: [String], category: String) -> AnyPublisher<Card, Error> {
        let fetchPublishers = words.map { word -> AnyPublisher<Card, Error> in
            let card = Card(context: viewContext)
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
                        let newMeaning = Meaning(context: self.viewContext)
                        newMeaning.partOfSpeech = meaning.partOfSpeech ?? "Unknown"
                        
                        meaning.definitions?.forEach { definition in
                            let newDefinition = Definition(context: self.viewContext)
                            newDefinition.definition = definition.definition
                            newDefinition.example = definition.example
                            newDefinition.antonyms = definition.antonyms?.joined(separator: ", ") ?? ""
                            newDefinition.synonyms = definition.synonyms?.joined(separator: ", ") ?? ""
                            
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
                        let imageUrl = ImageUrl(context: self.viewContext)
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
        persistence.saveContext()
    }
    
    func addDefaultCategory(completion: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Category 1")

        do {
            let categories = try viewContext.fetch(fetchRequest)
            guard categories.isEmpty else { return }
            
            let newCategory = CardCategory(context: viewContext)
            newCategory.name = "Category 1"
            self.categories.append(newCategory)
            
            persistence.saveContext()
            completion()
            
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
}
