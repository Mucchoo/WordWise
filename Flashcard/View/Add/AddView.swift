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
    @State private var pickerSelected = 1
    @State private var showingAlert = false
    @State private var textFieldInput = ""

    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines. Both words and phrases are available.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach\nplum\nRome was not built in a day\nAll that glitters is not gold\nEvery cloud has a silver lining"
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
                                Text("Option 1").tag(1)
                                Text("Option 2").tag(2)
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
                    Text("WORDS / PHRASES")
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

            }.background(Color(UIColor.systemGroupedBackground)) // Use systemGroupedBackground color
        }
        .alert("Add Category", isPresented: $showingAlert) {
            TextField("category name", text: $textFieldInput)
            Button("Add", role: .none, action: addCategory)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enter the new category name.")
        }
    }
    
    func addCategory() {
        
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
