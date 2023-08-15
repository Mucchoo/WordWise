//
//  CardListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State private var searchBarText = ""
    @State private var cardList: [Card] = []
    @State private var selectMode = false
    @State private var selectedCards: [Card] = []
    @State private var changeCategoryDestination = ""
    @State var categoryName = "" {
        didSet {
            changeCategoryDestination = categoryName
        }
    }

    @State private var showingChangeCategoryView = false
    @State private var showingResetMasteryRateyAlert = false
    @State private var showingDeleteCardsAlert = false
    
    var body: some View {
        VStack {
            SearchBar(text: $searchBarText)
            ScrollView {
                VStack {
                    LazyVStack {
                        ForEach(cardList, id: \.id) { card in
                            CardRowView(card: card, lastCardId: $cardList.last?.id, selectMode: $selectMode, selectedCards: $selectedCards) {
                                self.updateCardList()
                            }
                        }
                    }
                    .modifier(BlurBackground())
                }
            }
        }
        .background(BackgroundView())
        .background(AlertControllerView(
            isPresented: $showingChangeCategoryView,
            title: "Change Category",
            message: "Select new category for the \(selectedCards.count) cards.",
            content: {
                VStack {
                    Picker("", selection: $changeCategoryDestination) {
                        ForEach(dataViewModel.categories, id: \.self) { category in
                            Text(category.name ?? "").tag(category.name)
                        }
                    }
                }
            },
            customAction: .init(title: "Change", style: .default, handler: { _ in
                dataViewModel.changeCategory(of: selectedCards, newCategory: changeCategoryDestination)
            }))
        )
        .navigationBarTitle(categoryName, displayMode: .large)
        .navigationBarItems(leading:
            Group {
                if selectMode {
                    if selectedCards.count == 0 {
                        Text("Select Cards")
                            .foregroundStyle(Color.white)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .frame(width: 120, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.gray)
                            )
                    } else {
                        Menu("Actions...") {
                            Button(action: {
                                showingChangeCategoryView = true
                            }) {
                                Label("Change Category", systemImage: "folder.fill")
                            }

                            Button(action: {
                                showingResetMasteryRateyAlert = true
                            }) {
                                Label("Reset Mastery Rate", systemImage: "arrow.counterclockwise")
                            }

                            Button(action: {
                                showingDeleteCardsAlert = true
                            }) {
                                Label("Delete Cards", systemImage: "trash.fill")
                                    .foregroundColor(Color.red)
                            }
                        }
                        .foregroundStyle(Color.white)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .frame(width: 120, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(Color.blue)
                        )
                    }
                } else {
                    EmptyView()
                }
            },
            trailing: Button(action: {
                selectMode.toggle()
            }) {
                Text(selectMode ? "Cancel" : "Select")
                    .foregroundStyle(Color.white)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .frame(width: 80, height: 30)
                    .background(RoundedRectangle(cornerRadius: 15).foregroundStyle(Color.blue))
            }
        )
        .onReceive(dataViewModel.$cards) { _ in
            updateCardList()
        }
        .onChange(of: searchBarText) { _ in
            updateCardList()
        }
        .alert("Do you want to delete the \(selectedCards.count) cards?", isPresented: $showingDeleteCardsAlert) {
            Button("Delete", role: .destructive) {
                dataViewModel.deleteCards(selectedCards)
                selectMode = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This operation cannot be undone.")
        }
        
        .alert("Do you want to reset mastery rate for the \(selectedCards.count) cards?", isPresented: $showingResetMasteryRateyAlert) {
            Button("Reset", role: .destructive) {
                dataViewModel.resetMasteryRate(cards: selectedCards)
                selectMode = false
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This operation cannot be undone.")
        }
    }
    
    private func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = card.category == categoryName
            let cardText = card.text ?? ""
            let searchTextFilter = cardText.contains(searchBarText) || searchBarText.isEmpty
            return categoryFilter && searchTextFilter
        }
        cardList = filteredCards
    }
}

#Preview {
    CardListView()
        .injectMockDataViewModelForPreview()
}
