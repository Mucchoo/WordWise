//
//  CardsView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/20/23.
//

import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel
    
    init(container: DIContainer, type: CardsViewModel.ViewType) {
        _viewModel = StateObject(wrappedValue: .init(container: container, type: type))
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    LazyVStack {
                        ForEach(viewModel.cards, id: \.id) { card in
                            cardRow(card)
                        }
                    }
                    .blurBackground()
                }
            }
        }
        .gradientBackground()
        .navigationBarTitle(viewModel.title, displayMode: .large)
    }
    
    private func cardRow(_ card: Card) -> some View {
        return VStack {
            HStack {
                Text(card.text ?? "")
                    .foregroundColor(.primary)
                Spacer()

                if viewModel.title == "Upcoming Cards" {
                    Text(viewModel.getRemainingDays(card.nextLearningDate))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.navy)
                        .foregroundStyle(Color.white)
                        .bold()
                        .cornerRadius(8)
                }

                Text(card.rate.stringValue() + "%")
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.ocean)
                    .foregroundStyle(Color.white)
                    .bold()
                    .cornerRadius(8)
            }

            if card.id != viewModel.cards.last?.id {
                Divider()
            }
        }
    }
}

//#Preview {
//    CardsView(type: .todays)
//        .injectMockDataViewModelForPreview()
//}
