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
    @Published var studyingCards: [Card] = []
    @Published var todaysCards: [Card] = []
    @Published var upcomingCards: [Card] = []
    @Published var requestedWordCount = 0
    @Published var fetchedWordCount = 0
    @Published var isDataLoaded = false
    
    private var isAddingDefaultCategory = false
    var cancellables = Set<AnyCancellable>()
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
                deleteDuplicatedCategory()
                
                isDataLoaded = true
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func deleteDuplicatedCategory() {
        let groupedCategories = Dictionary(grouping: categories) { (category: CardCategory) in
            return category.name ?? ""
        }
        
        let duplicateGroups = groupedCategories.filter { $1.count > 1 }
        
        for (name, duplicateCategories) in duplicateGroups {
            print("Found \(duplicateCategories.count) duplicates for category named: \(name)")
            
            let categoriesToDelete = duplicateCategories.dropFirst()
            
            for category in categoriesToDelete {
                viewContext.delete(category)
                categories.removeAll { $0 == category }
            }
        }
        
        persistence.saveContext()
    }
    
    func updateCard(id: UUID, text: String, category: String, rate: Int16) {
        guard let card = cards.first(where: { $0.id == id }) else { return }
        card.text = text
        card.category = category
        card.masteryRate = rate
        
        var nextLearningDate: Int
        switch card.rate {
        case .zero:
            nextLearningDate = 1
        case .twentyFive:
            nextLearningDate = 2
        case .fifty:
            nextLearningDate = 4
        case .seventyFive:
            nextLearningDate = 7
        case .oneHundred:
            nextLearningDate = 14
        }
        
        card.nextLearningDate = Calendar.current.date(byAdding: .day, value: nextLearningDate, to: Date())
        card.masteryRate += 1
        
        persistence.saveContext()
        loadData()
    }
    
    func deleteCard(_ card: Card) {
        viewContext.delete(card)
        persistence.saveContext()
        loadData()
    }
    
    func deleteCards(_ cards: [Card]) {
        cards.forEach { card in
            viewContext.delete(card)
        }
        
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
        categories.removeAll(where: { $0.name == category.name })
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", name)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(batchDeleteRequest)
        } catch {
            print("Failed to execute batch delete: \(error)")
        }
        
        persistence.saveContext()
        loadData()
    }
    
    func changeCategory(of cards: [Card], newCategory: String) {
        cards.forEach { card in
            card.category = newCategory
        }
        
        persistence.saveContext()
        loadData()
    }
    
    func changeMasteryRate(of cards: [Card], rate: String) {
        var masteryRate: Int16 = 0
        
        switch rate {
        case "25%":
            masteryRate = 1
        case "50%":
            masteryRate = 2
        case "75%":
            masteryRate = 3
        case "100%":
            masteryRate = 4
        default:
            break
        }
        
        cards.forEach { card in
            card.masteryRate = masteryRate
        }
        
        persistence.saveContext()
        loadData()
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
                card.category = category

                let fetchCardData = self.cardService.fetchDefinitions(word: word)
                let fetchImagesData = self.cardService.fetchImages(word: word)

                return Publishers.Zip(fetchCardData, fetchImagesData)
                    .receive(on: DispatchQueue.main)
                    .flatMap { cardResponse, imageUrls -> AnyPublisher<Card, Never> in
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
                        
                        self.fetchedWordCount += 1
                                                
                        let downloadImages = imageUrls.enumerated().map { index, url -> AnyPublisher<Data, Error> in
                            return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
                                .map(\.data)
                                .mapError { $0 as Error }
                                .eraseToAnyPublisher()
                        }

                        return Publishers.MergeMany(downloadImages)
                            .collect()
                            .tryMap { [weak self] imagesData in
                                guard let self = self else { return card }
                                
                                for (index, data) in imagesData.enumerated() {
                                    let imageData = ImageData(context: self.viewContext)
                                    imageData.data = data
                                    imageData.priority = Int64(index)
                                    imageData.retryFlag = imageUrls[index] == "error"
                                    card.addToImageDatas(imageData)
                                }
                                
                                return card
                            }
                            .catch { error in
                                print("Failed downloading images: \(error)")
                                return Just(card)
                            }
                            .eraseToAnyPublisher()
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
        let cardsFailedFetchingImages = cards.filter { (card: Card) -> Bool in
            if let imageDatas = card.imageDatas as? Set<ImageData> {
                return imageDatas.contains { (imageData: ImageData) in
                    return imageData.retryFlag
                }
            }
            return false
        }
        
        print("retryFetchingImages for: \(cardsFailedFetchingImages.count) cards")
        guard !cardsFailedFetchingImages.isEmpty else { return }
        
        let fetchPublishers = cardsFailedFetchingImages.publisher
            .buffer(size: cardsFailedFetchingImages.count, prefetch: .keepFull, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(20)) { card -> AnyPublisher<Void, Never> in
                let fetchImagesData = self.cardService.fetchImages(word: card.unwrappedText)
                
                return fetchImagesData
                    .receive(on: DispatchQueue.main)
                    .flatMap { imageUrls -> AnyPublisher<Void, Never> in
                        card.imageDatas = nil
                        
                        let downloadImages = imageUrls.enumerated().map { index, url -> AnyPublisher<Data, Error> in
                            return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
                                .map(\.data)
                                .mapError { $0 as Error }
                                .eraseToAnyPublisher()
                        }
                        
                        return Publishers.MergeMany(downloadImages)
                            .collect()
                            .tryMap { imagesData in
                                for (index, data) in imagesData.enumerated() {
                                    let imageData = ImageData(context: self.viewContext)
                                    imageData.data = data
                                    imageData.priority = Int64(index)
                                    imageData.retryFlag = imageUrls[index] == "error"
                                    card.addToImageDatas(imageData)
                                }
                            }
                            .catch { error in
                                print("Failed downloading images: \(error)")
                                return Just(())
                            }
                            .map { _ in () }
                            .eraseToAnyPublisher()
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
            card.masteryRate = 0
            card.lastHardDate = nil
            card.nextLearningDate = nil
        }
        persistence.saveContext()
    }
    
    func resetMasteryRate(cards: [Card]) {
        cards.forEach { card in
            card.masteryRate = 0
        }
        persistence.saveContext()
        loadData()
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