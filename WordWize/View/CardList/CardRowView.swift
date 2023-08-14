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
    
    let card: Card
    let lastCardId: UUID?
    let updateCardList: () -> Void

    var body: some View {
        VStack {
            Button(action: {
                setupDetailView(card)
            }) {
                HStack {
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
}
