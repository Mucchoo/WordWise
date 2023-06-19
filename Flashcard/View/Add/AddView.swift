//
//  AddView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    
    @State private var flashcards = [String]()
    @State private var isEditing = false
    @State private var cardText = ""
    @State private var isLoading = false
    @State private var progress: Float = 0.0
    private let initialPlaceholder = "Multiple cards can be added by adding new lines. Both words and phrases are available.\n\npineapple\nstrawberry\ncherry\nblueberry\npeach\nplum\nRome was not built in a day\nAll that glitters is not gold\nEvery cloud has a silver lining"
    @ObservedObject var fetcher = WordFetcher()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { self.isEditing ? self.cardText : self.initialPlaceholder },
                        set: { self.cardText = $0 }
                    ))
                    .background(Color.white)
                    .foregroundColor(isEditing ? .primary : .secondary)
                    .onTapGesture {
                        self.isEditing = true
                    }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                .padding()
                
                Button(action: {
                    addCard()
                }) {
                    Text("Add \(cardText.split(separator: "\n").count) Cards")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardText == initialPlaceholder)
            }
            .padding()
            .navigationBarTitle("Add Cards", displayMode: .large)
        }
    }
    
    func addCard() {
        guard cardText != "" else { return }
        let words = cardText.split(separator: "\n")
        let totalWords = words.count
        for word in words {
            self.isLoading = true
            self.fetcher.fetch(word: String(word)) { success in
                guard success else { return }
                self.progress += 1.0 / Float(totalWords)
                if self.progress >= 1.0 {
                    self.isLoading = false
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
                        newDefinition.definition = definition.example
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
                
                try? viewContext.save()
            }
        }
        
        cardText = ""
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
    }
}

struct WordDefinition: Codable, Identifiable {
    let id = UUID()
    let word: String
    let phonetic: String?
    let phonetics: [Phonetic]?
    let origin: String?
    let meanings: [Meaning]?

    private enum CodingKeys: String, CodingKey {
        case word, phonetic, phonetics, origin, meanings
    }

    struct Phonetic: Codable {
        let text: String?
        let audio: String?
    }

    struct Meaning: Codable, Identifiable {
        let id = UUID()
        let partOfSpeech: String?
        let definitions: [Definition]?

        private enum CodingKeys: String, CodingKey {
            case partOfSpeech, definitions
        }

        struct Definition: Codable, Identifiable {
            let id = UUID()
            let definition: String?
            let example: String?
            let synonyms: [String]?
            let antonyms: [String]?

            private enum CodingKeys: String, CodingKey {
                case definition, example, synonyms, antonyms
            }
        }
    }
}

class WordFetcher: ObservableObject {
    @Published var wordDefinition: WordDefinition?

    func fetch(word: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            print("No data for: \(word)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([WordDefinition].self, from: data) {
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
