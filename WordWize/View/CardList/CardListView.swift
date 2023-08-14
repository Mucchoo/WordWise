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
    @State private var isFirstAppearance = true
    @State private var showingCategorySheet = false
    
    @State var categoryName = ""
    @State private var searchBarText = ""
    @State private var cardList: [Card] = []

    @State private var filterCategories: [String] = []
    @State private var filterStatus: [Int16]  = [0, 1, 2]
        
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    LazyVStack {
                        ForEach(cardList, id: \.id) { card in
                            CardRowView(card: card, lastCardId: $cardList.last?.id) {
                                self.updateCardList()
                            }
                        }
                    }
                    .modifier(BlurBackground())
                }
            }
        }
        .background(BackgroundView())
        .navigationBarTitle(categoryName, displayMode: .large)
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
    
    private func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let statusFilter = filterStatus.contains { $0 == card.status }
            let categoryFilter = filterCategories.contains { $0 == card.category }
            return statusFilter && categoryFilter
        }
        cardList = filteredCards
    }
}
