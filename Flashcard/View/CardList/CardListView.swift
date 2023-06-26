//
//  CardListView.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<CardCategory>
    @FocusState var isFocused: Bool
    
    @State private var flashcards = [String]()
    @State private var isEditing = false
    @State private var cardText = ""
    @State private var isLoading = false
    @State private var progress: Float = 0.0
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var fetchFailedWords: [String] = []
    @State private var navigateToCardDetail: Bool = false
    
    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    @ObservedObject var fetcher = WordFetcher()
    
    var body: some View {
        NavigationView {
            if cards.isEmpty {
                NoCardView()
            } else {
                VStack {
                    List {
                        Section(header: Text("category")) {
                            Picker("Category", selection: $pickerSelected) {
                                ForEach(categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Section(header: Text("Cards")) {
                            ForEach(cards) { card in
                                Button(action: {
                                    self.navigateToCardDetail = true
                                }) {
                                    HStack{
                                        Image(systemName: card.status == 0 ? "checkmark.circle.fill" : card.status == 1 ? "pencil.circle.fill" : "star.circle.fill")
                                            .foregroundColor(card.status == 0 ? .blue : card.status == 1 ? .red : .yellow)
                                            .font(.system(size: 16))
                                            .fontWeight(.black)
                                            .frame(width: 20, height: 20, alignment: .center)
                                        
                                        Text(card.text ?? "Unknown")
                                            .foregroundColor(Color(UIColor(.primary)))
                                        Spacer()
                                    }
                                }
                            }
                            .onDelete(perform: deleteCards)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    NavigationLink(destination: CardDetailView(), isActive: $navigateToCardDetail) {
                        EmptyView()
                    }
                }
                .navigationBarTitle("Cards", displayMode: .large)
            }
        }
    }
    
    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            let card = cards[index]
            viewContext.delete(card)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed deleteCards: \(error)")
        }
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView()
    }
}
