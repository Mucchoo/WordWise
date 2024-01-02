//
//  CardsViewModel.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import SwiftData

class CardsViewModel: ObservableObject {
    enum ViewType {
        case todays, upcoming
    }
    
    @Published var cards: [Card] = []
    var title = ""

    init(container: DIContainer, type: ViewType) {
        var descriptor = FetchDescriptor<Card>()
        let allCards = (try? container.modelContext.fetch(descriptor)) ?? []
        
        switch type {
        case .todays:
            cards = allCards.filter { $0.isTodayOrBefore }
            title = "Todays Cards"
        case .upcoming:
            cards = allCards.filter { $0.isUpcoming }
            title = "Upcoming Cards"
        }
    }

    func getRemainingDays(_ nextLearningDate: Date?) -> String {
        guard let nextLearningDate = nextLearningDate else { return "" }
        
        let components = Calendar.current.dateComponents([.day], from: Date(), to: nextLearningDate)
        let remainingDays = components.day!
        
        if remainingDays == 0 {
            return "1 day left"
        } else {
            return "\(remainingDays + 1) days left"
        }
    }
}
