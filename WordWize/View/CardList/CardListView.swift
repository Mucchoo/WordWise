//
//  CardListView.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/25/23.
//

import SwiftUI

struct CardListView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State var categoryName = ""
    @State private var searchBarText = ""
    @State private var cardList: [Card] = []
        
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
        .onReceive(dataViewModel.$cards) { _ in
            updateCardList()
        }
    }
    
    private func updateCardList() {
        let filteredCards = dataViewModel.cards.filter { card in
            let categoryFilter = card.category == categoryName
            return categoryFilter
        }
        cardList = filteredCards
    }
}
