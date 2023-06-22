//
//  AddView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/13/23.
//

import CoreData
import SwiftUI

struct AddCardView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<CardCategory>

    @State private var flashcards = [String]()
    @State private var isEditing = false
    @State private var cardText = ""
    @State private var isLoading = false
    @State private var progress: Float = 0.0
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""

    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    @ObservedObject var fetcher = WordFetcher()
    
    var body: some View {
        NavigationView {
            
            VStack {
                HStack {
                    Text("CATEGORY")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal, 30)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                        
                        HStack {
                            Picker("Options", selection: $pickerSelected) {
                                ForEach(categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            Spacer()
                        }
                    }
                    .frame(height: 44)
                                        
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text("Add Category")
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.leading, 10)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                HStack {
                    Text("WORDS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: Binding(
                        get: { self.isEditing ? self.cardText : self.initialPlaceholder },
                        set: { self.cardText = $0 }
                    ))
                    .foregroundColor(isEditing ? .primary : .secondary)
                    .onTapGesture {
                        self.isEditing = true
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                .animation(.default)
                .padding([.horizontal, .bottom])
                
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
                .disabled(cardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || cardText == initialPlaceholder)
                .padding([.horizontal, .bottom])
                .navigationBarTitle("Add Cards", displayMode: .large)

            }.background(Color(UIColor.systemGroupedBackground))
        }
        .alert("Add Category", isPresented: $showingAlert) {
            TextField("category name", text: $textFieldInput)
            Button("Add", role: .none, action: addCategory)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
        .onAppear {
            if categories.isEmpty {
                addDefaultCategory()
            }
        }
    }
    
    private func addDefaultCategory() {
        let fetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Category 1")

        do {
            let categories = try viewContext.fetch(fetchRequest)
            if categories.isEmpty {
                let newCategory = CardCategory(context: viewContext)
                newCategory.name = "Category 1"
                try viewContext.save()
            }
        } catch let error {
            print("Failed to fetch categories: \(error)")
        }
    }
    
    func addCategory() {
        let category = CardCategory(context: viewContext)
        category.name = textFieldInput
        PersistenceController.shared.saveContext()
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
                    print("Validation error: \(error), \(error as NSError).userInfo")
                }
                
                PersistenceController.shared.saveContext()
            }
        }
        
        cardText = ""
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

class WordFetcher: ObservableObject {
    @Published var wordDefinition: CardResponse?

    func fetch(word: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)") else {
            print("No data for: \(word)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
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
