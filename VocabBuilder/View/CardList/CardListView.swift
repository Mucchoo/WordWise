//
//  CardListView.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @ObservedObject var dataViewModel = DataViewModel.shared
    @FocusState var isFocused: Bool
    
    @State private var VocabBuilders = [String]()
    @State private var isEditing = false
    @State private var isLoading = false
    @State private var progress: Float = 0.0
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var fetchFailedWords: [String] = []
    @State private var navigateToCardDetail: Bool = false
    @State private var cardList: [Card] = []
    @State private var isFirstAppearance = true
    @State private var showingCategorySheet = false
    
    @State private var cardText = ""
    @State private var cardId: UUID?
    @State private var cardStatus: Int16 = 0
    @State private var cardFailedTimes = 0
    @State private var cardCategory = ""

    @State private var filterFailedTimes = 0
    @State private var filterCategories: [String] = []
    @State private var filterStatus: [Int16]  = [0, 1, 2]
    
    private let statusArray: [CardStatus]  = [.init(text: "learned", value: 0), .init(text: "learning", value: 1), .init(text: "new", value: 2)]
    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    
    private func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let statusFilter = filterStatus.contains { $0 == card.status }
            let failedTimesFilter = card.failedTimes >= filterFailedTimes
            let categoryFilter = filterCategories.contains { $0 == card.category }
            print("card: \(card.text) status: \(statusFilter) failedTimes: \(failedTimesFilter) category: \(categoryFilter)")
            return statusFilter && failedTimesFilter && categoryFilter
        }
        cardList = filteredCards
    }
    
    var body: some View {
        if dataViewModel.cards.isEmpty {
            NoCardView(image: "BoyRight")
        } else {
            NavigationView {
                VStack {
                    ScrollView {
                        VStack {
                            StatusFilterView(filterStatus: $filterStatus)
                            
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Category")
                                    Spacer()
                                    
                                    Button {
                                        showingCategorySheet.toggle()
                                    } label: {
                                        Text(filterCategories.map { $0 }.joined(separator: ", "))
                                            .padding(.vertical, 8)
                                    }
                                    .padding([.leading, .trailing])
                                    .sheet(isPresented: $showingCategorySheet) {
                                        CategoryList(categories: $filterCategories)
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Failed Times")
                                    Spacer()
                                    NumberPicker(value: $filterFailedTimes, labelText: "or more times", options: Global.failedTimeOptions)
                                }
                            }
                            .modifier(BlurBackground())
                            
                            VStack {
                                ForEach(cardList, id: \.id) { card in
                                    VStack {
                                        Button(action: {
                                            cardId = card.id
                                            cardText = card.text ?? ""
                                            cardStatus = card.status
                                            cardCategory = card.category ?? ""
                                            cardFailedTimes = Int(card.failedTimes)
                                            navigateToCardDetail = true
                                        }) {
                                            HStack{
                                                Image(systemName: card.status == 0 ? "checkmark.circle.fill" : card.status == 1 ? "flame.circle.fill" : "star.circle.fill")
                                                    .foregroundColor(card.status == 0 ? Color("Navy") : card.status == 1 ? Color("Blue") : Color("Teal"))
                                                    .font(.system(size: 16))
                                                    .fontWeight(.black)
                                                    .frame(width: 20, height: 20, alignment: .center)
                                                
                                                Text(card.text ?? "Unknown")
                                                    .foregroundColor(Color(UIColor(.primary)))
                                                Spacer()
                                            }
                                        }
                                        if card.id != cardList.last?.id {
                                            Divider()
                                        }
                                    }
                                    .sheet(isPresented: $navigateToCardDetail) {
                                        List {
                                            HStack {
                                                Text("Name")
                                                Spacer()
                                                Text("\(cardList.first { $0.id == cardId }?.text ?? "")")
                                            }
                                            Picker("Category", selection: $cardCategory) {
                                                ForEach(dataViewModel.categories) { category in
                                                    let name = category.name ?? ""
                                                    Text(name).tag(name)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            
                                            Picker("Status", selection: $cardStatus) {
                                                ForEach(statusArray, id: \.self) { status in
                                                    Text("\(status.text)").tag(status.value)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            
                                            HStack {
                                                Text("Failed Times")
                                                Spacer()
                                                NumberPicker(value: $filterFailedTimes, labelText: "times", options: Global.failedTimeOptions)
                                            }
                                        }
                                        .presentationDetents([.medium])
                                    }
                                    .onChange(of: navigateToCardDetail) { newValue in
                                        if !newValue, let cardId = cardId {
                                            DataViewModel.shared.updateCard(id: cardId, text: cardText, category: cardCategory, status: cardStatus, failedTimesIndex: Int(cardFailedTimes))
                                        }
                                    }
                                }
                                .onDelete(perform: DataViewModel.shared.deleteCard)
                            }
                            .modifier(BlurBackground())
                        }
                    }
                }
                .onAppear {
                    guard isFirstAppearance else { return }
                    filterCategories = dataViewModel.categories.map { $0.name ?? "" }
                    isFirstAppearance = false
                }
                .background(BackgroundView())
                .navigationBarTitle("Cards", displayMode: .large)
                .onReceive(dataViewModel.$cards) { _ in
                    updateCardList()
                }
                .onChange(of: filterFailedTimes) { _ in
                    updateCardList()
                }
                .onChange(of: filterCategories) { _ in
                    updateCardList()
                }
                .onChange(of: filterStatus) { _ in
                    updateCardList()
                }
            }
        }
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView()
    }
}
