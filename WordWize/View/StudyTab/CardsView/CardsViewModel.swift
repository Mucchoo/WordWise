//
//  CardsViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI

class CardsViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel

    @Published var cards: [Card] = []
    var title: String = ""

    init(type: CardsView.ViewType) {
        switch type {
        case .todays:
            cards = dataViewModel.todaysCards
            title = "Todays Cards"
        case .upcoming:
            cards = dataViewModel.upcomingCards
            title = "Upcoming Cards"
        }
    }

    func getRemainingDays(_ nextLearningDate: Date?) -> String {
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
