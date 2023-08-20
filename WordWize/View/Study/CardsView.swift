//
//  CardsView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/20/23.
//

import SwiftUI

struct CardsView: View {
    enum ViewType {
        case todays, upcoming
    }
    
    @EnvironmentObject var dataViewModel: DataViewModel
    let type: ViewType
    
    var body: some View {
        let cards: [Card]
        let title: String

        if type == .todays {
            cards = dataViewModel.todaysCards
            title = "Todays Cards"
        } else {
            cards = dataViewModel.upcomingCards
            title = "Upcoming Cards"
        }

        return VStack {
            ScrollView {
                VStack {
                    LazyVStack {
                        ForEach(cards, id: \.id) { card in
                            VStack {
                                HStack {
                                    Text(card.text ?? "")
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
                                
                                if card.id != cards.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .modifier(BlurBackground())
                }
            }
        }
        .background(BackgroundView())
        .navigationBarTitle(title, displayMode: .large)
    }
}

#Preview {
    CardsView(type: .todays)
        .injectMockDataViewModelForPreview()
}
