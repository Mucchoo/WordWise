//
//  CardsViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI

class CardsViewModel: ObservableObject {
    enum ViewType {
        case todays, upcoming
    }
    
    @Published var cards: [Card] = []
    var title = ""

    init(container: DIContainer, type: ViewType) {
        switch type {
        case .todays:
            cards = container.appState.todaysCards
            title = "Todays Cards"
        case .upcoming:
            cards = container.appState.upcomingCards
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
