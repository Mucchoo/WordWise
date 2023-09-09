//
//  CardsView.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/20/23.
//

import SwiftUI

struct CardsView: View {
    @StateObject var vm: CardsViewModel
    
    init(vm: CardsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.cards, id: \.id) { card in
                        cardRow(card)
                    }
                }
                .blurBackground()
            }
        }
        .gradientBackground()
        .navigationBarTitle(vm.title, displayMode: .large)
    }
    
    func cardRow(_ card: Card) -> some View {
        return VStack {
            HStack {
                Text(card.text ?? "")
                    .foregroundColor(.primary)
                Spacer()

                if vm.title == "Upcoming Cards" {
                    Text(vm.getRemainingDays(card.nextLearningDate))
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

            if card.id != vm.cards.last?.id {
                Divider()
            }
        }
    }
}

#Preview {
    let container: DIContainer = .mock()
    container.appState.upcomingCards = container.appState.cards
    
    return CardsView(vm: .init(container: container, type: .upcoming))
}
