//
//  CardManager.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

class CardManager {
    static let shared = CardManager()
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @ObservedObject var fetcher = WordFetcher()
    
    let maximumCardOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000]
    let failedTimeOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    let statusArray  = [CardStatus(text: "learned", value: 0), CardStatus(text: "learning", value: 1), CardStatus(text: "new", value: 2)]

    
    func updateCard(id: UUID, text: String, category: String, status: Int16, failedTimesIndex: Int) {
        print("updateCard id: \(id) text: \(text) category: \(category) status: \(status) failedTimesIndex: \(failedTimesIndex)")
        if let card = cards.first(where: { $0.id == id }) {
            card.text = text
            card.category = category
            card.status = status
            card.failedTimes = Int64(failedTimeOptions[failedTimesIndex])
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
    }
    
    func addCard(text: String, completion: (([String]) -> (Void))? = nil) {
        guard text != "" else { return }
        let words = text.split(separator: "\n")
        let totalWords = words.count
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
                
                PersistenceController.shared.saveContext()
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [self] in
            cards.forEach { card in
                AudioManager.shared.downloadAudio(card: card)
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

struct CardStatus: Hashable {
    let text: String
    let value: Int16
}
