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
    @State private var masteryRate: Int16 = 0
    @State private var cardCategory = ""
    @State private var navigateToCardDetail: Bool = false
    @State private var isCardSelected = false
    
    let card: Card
    let lastCardId: UUID?
    @Binding var selectMode: Bool
    @Binding var selectedCards: [Card]
    let updateCardList: () -> Void
    
    var body: some View {
        VStack {
            Button(action: {
                if selectMode {
                    selectCard()
                } else {
                    setupDetailView(card)
                }
            }) {
                HStack {
                    if selectMode {
                        Image(systemName: isCardSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                            .fontWeight(isCardSelected ? .black : .regular)
                            .frame(width: 20, height: 20, alignment: .center)
                    }
                    
                    Text(card.text ?? "Unknown")
                        .foregroundColor(.primary)
                    Spacer()
                    Text((MasteryRate(rawValue: card.masteryRate) ?? .zero).stringValue() + "%")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.ocean)
                        .foregroundStyle(Color.white)
                        .bold()
                        .cornerRadius(8)
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
                masteryRate: $masteryRate,
                cardId: cardId,
                deleteAction: {
                    dataViewModel.deleteCard(card)
                    navigateToCardDetail = false
                    updateCardList()
                },
                updateAction: {
                    if let cardId = cardId {
                        dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, rate: masteryRate)
                        updateCardList()
                    }
                }
            )
        }
        .onChange(of: navigateToCardDetail) { newValue in
            if !newValue, let cardId = cardId {
                dataViewModel.updateCard(id: cardId, text: cardText, category: cardCategory, rate: masteryRate)
            }
        }
    }
    
    private func setupDetailView(_ card: Card) {
        cardId = card.id
        cardText = card.text ?? ""
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
