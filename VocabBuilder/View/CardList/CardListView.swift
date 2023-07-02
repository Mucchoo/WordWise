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

    private let statusArray: [CardStatus]  = [.init(text: "learned", value: 0), .init(text: "learning", value: 1), .init(text: "new", value: 2)]
    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
        
    var body: some View {
        NavigationView {
            if cards.isEmpty {
                NoCardView(image: "BoyRight")
            } else {
                VStack {
                    ScrollView {
                        VStack {
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Category")
                                    Spacer()
                                    Picker("Category", selection: $pickerSelected) {
                                        ForEach(categories) { category in
                                            let name = category.name ?? ""
                                            Text(name).tag(name)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Failed Times")
                                    Spacer()
                                    NumberPicker(value: $failedTimes, labelText: "or more times", options: Global.failedTimeOptions)
                                }
                            }
                            .modifier(BlurBackground())
                            
                            VStack {
                                ForEach(cards.indices) { index in
                                    VStack {
                                        Button(action: {
                                            selectedCardId = cards[index].id
                                            cardText = cards[index].text ?? ""
                                            selectedStatus = cards[index].status
                                            selectedCategory = cards[index].category ?? ""
                                            selectedFailedTimes = Int(cards[index].failedTimes)
                                            navigateToCardDetail = true
                                        }) {
                                            HStack{
                                                Image(systemName: cards[index].status == 0 ? "checkmark.circle.fill" : cards[index].status == 1 ? "pencil.circle.fill" : "star.circle.fill")
                                                    .foregroundColor(cards[index].status == 0 ? .blue : cards[index].status == 1 ? .red : .yellow)
                                                    .font(.system(size: 16))
                                                    .fontWeight(.black)
                                                    .frame(width: 20, height: 20, alignment: .center)
                                                
                                                Text(cards[index].text ?? "Unknown")
                                                    .foregroundColor(Color(UIColor(.primary)))
                                                Spacer()
                                            }
                                        }
                                        if index < cards.count - 1 {
                                            Divider()
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
                                                ForEach(statusArray, id: \.self) { status in
                                                    Text("\(status.text)").tag(status.value)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            
                                            HStack {
                                                Text("Failed Times")
                                                Spacer()
                                                NumberPicker(value: $selectedFailedTimes, labelText: "times", options: Global.failedTimeOptions)
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
                            .modifier(BlurBackground())
                        }
                    }
                }
                .background(BackgroundView())
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
