//
//  CardListView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) var cards: FetchedResults<Card>
    @FetchRequest(sortDescriptors: []) var categories: FetchedResults<CardCategory>
    @FocusState var isFocused: Bool
    
    @State private var VocabBuilders = [String]()
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
    @State private var failedTimes = 0
    @State private var selectedCardId: UUID?
    @State private var selectedStatus: Int16 = 0
    @State private var selectedCategory = ""
    @State private var selectedFailedTimes = 0
    @State private var initialAnimation = false

    let failedTimeOptions = CardManager.shared.failedTimeOptions
    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    @ObservedObject var fetcher = WordFetcher()
    
    var body: some View {
        NavigationView {
            if cards.isEmpty {
                NoCardView(image: "BoyRight")
            } else {
                VStack {
                    List {
                        Section(header: Text("filter")) {
                            Picker("Category", selection: $pickerSelected) {
                                ForEach(categories) { category in
                                    let name = category.name ?? ""
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            HStack {
                                Text("Failed Times")
                                Spacer()
                                NumberPicker(value: $failedTimes, labelText: "or more times", options: failedTimeOptions)
                            }
                        }
                        
                        Section(header: Text("Cards")) {
                            ForEach(cards) { card in
                                Button(action: {
                                    selectedCardId = card.id
                                    cardText = card.text ?? ""
                                    selectedStatus = card.status
                                    selectedCategory = card.category ?? ""
                                    selectedFailedTimes = Int(card.failedTimes)
                                    navigateToCardDetail = true
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
                                .sheet(isPresented: $navigateToCardDetail) {
                                    List {
                                        HStack {
                                            Text("Name")
                                            Spacer()
                                            Text("\(cards.first { $0.id == selectedCardId }?.text ?? "")")
                                        }
                                        Picker("Category", selection: $selectedCategory) {
                                            ForEach(categories) { category in
                                                let name = category.name ?? ""
                                                Text(name).tag(name)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        
                                        Picker("Status", selection: $selectedStatus) {
                                            ForEach(CardManager.shared.statusArray, id: \.self) { status in
                                                Text("\(status.text)").tag(status.value)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        
                                        HStack {
                                            Text("Failed Times")
                                            Spacer()
                                            NumberPicker(value: $selectedFailedTimes, labelText: "times", options: failedTimeOptions)
                                        }
                                    }
                                    .presentationDetents([.medium])
                                }
                                .onChange(of: navigateToCardDetail) { newValue in
                                    if !newValue, let selectedCardId = selectedCardId {
                                        CardManager.shared.updateCard(id: selectedCardId, text: cardText, category: selectedCategory, status: selectedStatus, failedTimesIndex: Int(selectedFailedTimes))
                                    }
                                }
                            }
                            .onDelete(perform: CardManager.shared.deleteCard)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationBarTitle("Cards", displayMode: .large)
            }
        }
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView()
    }
}
