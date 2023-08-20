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
                                    Text(getRemainingDays(card.nextLearningDate))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.navy)
                                        .foregroundStyle(Color.white)
                                        .bold()
                                        .cornerRadius(8)
                                    Text(card.rate.stringValue() + "%")
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
    
    private func getRemainingDays(_ nextLearningDate: Date?) -> String {
        guard let nextLearningDate = nextLearningDate else { return "" }
        
        let components = Calendar.current.dateComponents([.day], from: Date(), to: nextLearningDate)
        
        if let remainingDays = components.day {
            if remainingDays == 0 {
                return "1 day left"
            } else {
                return "\(remainingDays + 1) days left"
            }
        }
        
        return ""
    }

}

#Preview {
    CardsView(type: .todays)
        .injectMockDataViewModelForPreview()
}
