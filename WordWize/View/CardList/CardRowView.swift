//
//  CardRowView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/14/23.
//

import SwiftUI

struct CardRowView: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    
    @State private var cardText = ""
    @State private var cardId: UUID?
    @State private var cardStatus: Int16 = 0
    @State private var cardCategory = ""
    @State private var navigateToCardDetail: Bool = false
    @State private var isCardSelected = false
    
    let card: Card
    let lastCardId: UUID?
    @Binding var manageMode: Bool
    @Binding var selectedCards: [Card]
    let updateCardList: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                if manageMode {
                    selectCard()
                } else {
                    setupDetailView(card)
                }
            }) {
                HStack {
                    if manageMode {
                        Image(systemName: isCardSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            .fontWeight(isCardSelected ? .black : .regular)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    
                    Text(card.text ?? "Unknown")
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
            if card.id != lastCardId {
                Divider()
            }
        }
        .sheet(isPresented: $navigateToCardDetail) {
            CardDetailSheetView(
                cardText: $cardText,
                categoryName: $cardCategory,
                cardStatus: $cardStatus,
                cardId: cardId,
                deleteAction: {
                    dataViewModel.deleteCard(card)
                    navigateToCardDetail = false
                    updateCardList()
                },
                updateAction: {
                    if let cardId = cardId {
                        dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, status: cardStatus)
                    }
                }
            )
        }
        .onChange(of: navigateToCardDetail) { newValue in
            if !newValue, let cardId = cardId {
                dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, status: cardStatus)
            }
        }
    }
    
    private func setupDetailView(_ card: Card) {
        cardId = card.id
        cardText = card.text ?? ""
        cardStatus = card.status
        cardCategory = card.category ?? ""
        navigateToCardDetail = true
    }
    
    private func selectCard() {
        isCardSelected.toggle()

        if isCardSelected {
            selectedCards.append(card)
        } else {
            selectedCards.removeAll(where: { $0 == card })
        }
    }
}
