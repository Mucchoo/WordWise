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

    @ObservedObject var viewModel: CardsViewModel
    
    init(type: ViewType) {
        viewModel = .init(type: type)
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    LazyVStack {
                        ForEach(viewModel.cards, id: \.id) { card in
                            VStack {
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
                    .modifier(BlurBackground())
                }
            }
        }
        .background(BackgroundView())
        .navigationBarTitle(viewModel.title, displayMode: .large)
    }
}

#Preview {
    CardsView(type: .todays)
        .injectMockDataViewModelForPreview()
}
