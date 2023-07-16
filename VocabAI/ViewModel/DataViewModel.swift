//
//  DataViewModel.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/2/23.
//

import CoreData
import SwiftUI

class DataViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    @Published var cards: [Card] = []
    @Published var categories: [CardCategory] = []
    @Published var cardsToStudy: [Card] = []
    @Published var cardList: [Card] = []
    
    var maxStatusCount: Int {
        let statuses = [0, 1, 2]
        let counts = statuses.map { status -> Int in
            return cards.filter { $0.status == Int16(status) }.count
        }
        return counts.max() ?? 0
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
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
            PersistenceController.shared.saveContext()
        }
    }
    
    func deleteCard(at offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            viewContext.delete(card)
        }
        PersistenceController.shared.saveContext()
    }
    
    func addCategory(name: String) {
        let category = CardCategory(context: viewContext)
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
        viewContext.delete(category)
        PersistenceController.shared.saveContext()
        
        DispatchQueue.main.async {
            self.categories.removeAll(where: { $0.name == category.name })
        }
    }
    
    func addCard(text: String, category: String, completion: (([String]) -> (Void))? = nil) {
        guard text != "" else { return }
        let lines = text.split(separator: "\n")
        let words = lines.map { String($0).trimmingCharacters(in: .whitespaces) }
        let cardsGroup = DispatchGroup()
        var fetchFailedWords: [String] = []
        
        cardsGroup.enter()
        for word in words {
            let cardGroup = DispatchGroup()
            let card = Card(context: viewContext)

            cardsGroup.enter()
            cardGroup.enter()
            
            fetch(word: word) { [self] response in
                guard let response = response else {
                    print("failed fetching \(word)")
                    fetchFailedWords.append(String(word))
                    cardGroup.leave()
                    return
                }
                
                card.id = UUID()
                card.text = String(word)
                card.status = 2
                card.failedTimes = 0
                card.category = category
                
                
                
                response.meanings?.forEach { meaning in
                    let newMeaning = Meaning(context: viewContext)
                    newMeaning.partOfSpeech = meaning.partOfSpeech ?? "Unknown"
                    
                    meaning.definitions?.forEach { definition in
                        let newDefinition = Definition(context: viewContext)
                        newDefinition.definition = definition.definition
                        newDefinition.example = definition.example
                        newDefinition.antonyms = definition.antonyms?.joined(separator: ", ") ?? ""
                        newDefinition.synonyms = definition.synonyms?.joined(separator: ", ") ?? ""
                        
                        newMeaning.addToDefinitions(newDefinition)
                    }
                    
                    card.addToMeanings(newMeaning)
                }
                
                response.phonetics?.forEach { phonetic in
                    let newPhonetic = Phonetic(context: viewContext)
                    newPhonetic.audio = phonetic.audio
                    newPhonetic.text = phonetic.text
                    card.addToPhonetics(newPhonetic)
                }
                
                do {
                    try card.validateForInsert()
                } catch {
                    print("Validation error: \(error.localizedDescription), \(error as NSError).userInfo")
                }
                
                DispatchQueue.main.async {
                    self.cards.append(card)
                }

                PersistenceController.shared.saveContext()
                cardGroup.leave()
            }
            
            cardGroup.enter()
            fetchImages(word: word) { [self] urls in
                urls.enumerated().forEach { index, url in
                    let imageUrl = ImageUrl(context: viewContext)
                    imageUrl.urlString = url
                    imageUrl.priority = Int64(index)
                    card.addToImageUrls(imageUrl)
                }
                cardGroup.leave()
            }
            
            cardGroup.notify(queue: .main) {
                cardsGroup.leave()
            }
        }
        
        cardsGroup.notify(queue: .main) {
            completion?(fetchFailedWords)
        }
    }

    func resetLearningData() {
        cards.forEach { card in
            card.failedTimes = 0
            card.status = 2
        }
        PersistenceController.shared.saveContext()
    }
    
    func fetch(word: String, completion: @escaping ((CardResponse?) -> ())) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            print("No URL for: \(word)")
            return
        }
         
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
                
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode([CardResponse].self, from: data)
                completion(decodedResponse.first)
            } catch {
                print("Fetch failed: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func fetchImages(word: String, completion: @escaping (([String]) -> ())) {
        guard let url = URL(string: "https://pixabay.com/api/?key=\(Keys.imageApiKey)&q=\(word)") else {
            print("No image URL for: \(word)")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil, let data = data else {
                print("Failed to fetch Image: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ImageResponse.self, from: data)
                let urls = decodedResponse.hits.map { $0.webformatURL }
                completion(urls)
            } catch {
                print("Image Decode Failed: \(error.localizedDescription)")
                completion([])
            }
        }
        task.resume()
    }
}
