//
//  DataViewModel.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import CoreData
import SwiftUI

class DataViewModel: ObservableObject {
    static let shared = DataViewModel()
    
    var viewContext: NSManagedObjectContext
    @Published var cards: [Card] = []
    @Published var categories: [CardCategory] = []
    var fetcher = WordFetcher()

    private init() {
        viewContext = PersistenceController.shared.container.viewContext
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
    
    func addCard(text: String, completion: (([String]) -> (Void))? = nil) {
        guard text != "" else { return }
        let lines = text.split(separator: "\n")
        let words = lines.map { String($0).trimmingCharacters(in: .whitespaces) }
        let group = DispatchGroup()
        var fetchFailedWords: [String] = []
        
        for word in words {
            group.enter()
            self.fetcher.fetch(word: String(word)) { [self] success in
                guard success else {
                    print("failed fetching \(word)")
                    fetchFailedWords.append(String(word))
                    group.leave()
                    return
                }
                
                let card = Card(context: viewContext)
                card.id = UUID()
                card.text = String(word)
                card.status = 2
                card.failedTimes = 0
                
                self.fetcher.wordDefinition?.meanings?.forEach { meaning in
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
                
                self.fetcher.wordDefinition?.phonetics?.forEach { phonetic in
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
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [self] in
            cards.forEach { card in
                AudioViewModel.shared.downloadAudio(card: card)
            }
            
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
}

class WordFetcher: ObservableObject {
    @Published var wordDefinition: CardResponse?

    func fetch(word: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            print("No data for: \(word)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([CardResponse].self, from: data) {
                    DispatchQueue.main.async {
                        self.wordDefinition = decodedResponse.first
                        completion?(true)
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            completion?(false)
        }
        task.resume()
    }
}
