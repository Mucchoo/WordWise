//
//  CardListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    @FocusState var isFocused: Bool
    
    @State private var WordWizes = [String]()
    @State private var isEditing = false
    @State private var isLoading = false
    @State private var progress: Float = 0.0
    @State private var pickerSelected = ""
    @State private var showingAlert = false
    @State private var textFieldInput = ""
    @State private var showingFetchFailedAlert = false
    @State private var fetchFailedWords: [String] = []
    @State private var navigateToCardDetail: Bool = false
    @State private var isFirstAppearance = true
    @State private var showingCategorySheet = false
    
    @State private var cardText = ""
    @State private var cardId: UUID?
    @State private var cardStatus: Int16 = 0
    @State private var cardCategory = ""

    @State private var filterCategories: [String] = []
    @State private var filterStatus: [Int16]  = [0, 1, 2]
    
    private let statusArray: [CardStatus]  = [.init(text: "learned", value: 0), .init(text: "learning", value: 1), .init(text: "new", value: 2)]
    private let initialPlaceholder = "You can add cards using dictionary data. Multiple cards can be added by adding new lines.\n\nExample:\npineapple\nstrawberry\ncherry\nblueberry\npeach"
    
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
                                    .padding(.horizontal)
                                    .accessibilityIdentifier("cardListCategoryButton")
                                    .sheet(isPresented: $showingCategorySheet) {
                                        CategoryList(categories: $filterCategories)
                                    }
                                }
                            }
                            .modifier(BlurBackground())
                            
                            LazyVStack {
                                ForEach(dataViewModel.cardList, id: \.id) { card in
                                    VStack {
                                        Button(action: {
                                            cardId = card.id
                                            cardText = card.text ?? ""
                                            cardStatus = card.status
                                            cardCategory = card.category ?? ""
                                            navigateToCardDetail = true
                                        }) {
                                            HStack{
                                                Image(systemName: card.status == 0 ? "checkmark.circle.fill" : card.status == 1 ? "flame.circle.fill" : "star.circle.fill")
                                                    .foregroundColor(card.status == 0 ? .navy : card.status == 1 ? .ocean : .teal)
                                                    .font(.system(size: 16))
                                                    .fontWeight(.black)
                                                    .frame(width: 20, height: 20, alignment: .center)
                                                
                                                Text(card.text ?? "Unknown")
                                                    .foregroundColor(Color(UIColor(.primary)))
                                                Spacer()
                                            }
                                        }
                                        if card.id != dataViewModel.cardList.last?.id {
                                            Divider()
                                        }
                                    }
                                    .sheet(isPresented: $navigateToCardDetail) {
                                        VStack {
                                            VStack(spacing: 4) {
                                                HStack {
                                                    Text("Name")
                                                    Spacer()
                                                    Text("\(dataViewModel.cardList.first { $0.id == cardId }?.text ?? "")")
                                                }
                                                .padding(.horizontal)
                                                .padding(.vertical, 10)
                                                
                                                Divider()

                                                HStack {
                                                    Text("Category")
                                                    Spacer()
                                                    Picker("Category", selection: $cardCategory) {
                                                        ForEach(dataViewModel.categories) { category in
                                                            let name = category.name ?? ""
                                                            Text(name).tag(name)
                                                        }
                                                    }
                                                    .pickerStyle(MenuPickerStyle())
                                                }
                                                .padding(.leading)
                                                
                                                Divider()

                                                HStack {
                                                    Text("Status")
                                                    Spacer()
                                                    Picker("Status", selection: $cardStatus) {
                                                        ForEach(statusArray, id: \.self) { status in
                                                            Text("\(status.text)").tag(status.value)
                                                        }
                                                    }
                                                    .pickerStyle(MenuPickerStyle())
                                                }
                                                .padding(.leading)
                                            }
                                            .padding()
                                            .padding(.top)
                                            
                                            Button {
                                                dataViewModel.deleteCard(card)
                                                navigateToCardDetail = false
                                                updateCardList()
                                            } label: {
                                                Text("Delete Card")
                                                    .fontWeight(.bold)
                                                    .padding()
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.red)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(10)
                                                    .padding()
                                            }
                                            
                                            Spacer()
                                        }
                                        .presentationDetents([.medium])
                                    }
                                    .onChange(of: navigateToCardDetail) { newValue in
                                        if !newValue, let cardId = cardId {
                                            dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, status: cardStatus)
                                        }
                                    }
                                }
                            }
                            .modifier(BlurBackground())
                        }
                    }
                }
                .background(BackgroundView())
                .navigationBarTitle("Card List", displayMode: .large)
                .onAppear {
                    guard isFirstAppearance else { return }
                    filterCategories = dataViewModel.categories.map { $0.name ?? "" }
                    isFirstAppearance = false
                }
                .onReceive(dataViewModel.$cards) { _ in
                    updateCardList()
                }
                .onChange(of: filterCategories) { _ in
                    updateCardList()
                }
                .onChange(of: filterStatus) { _ in
                    updateCardList()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let statusFilter = filterStatus.contains { $0 == card.status }
            let categoryFilter = filterCategories.contains { $0 == card.category }
            return statusFilter && categoryFilter
        }
        dataViewModel.cardList = filteredCards
    }
}

struct CardListView_Previews: PreviewProvider {
    static var previews: some View {
        CardListView()
    }
}
