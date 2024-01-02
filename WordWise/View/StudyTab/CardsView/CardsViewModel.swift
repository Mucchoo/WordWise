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
        
        switch type {
        case .todays:
            descriptor.predicate = #Predicate { $0.isTodayOrBefore }
            cards = (try? container.modelContext.fetch(descriptor)) ?? []
            title = "Todays Cards"
        case .upcoming:
            descriptor.predicate = #Predicate { $0.isUpcoming }
            cards = (try? container.modelContext.fetch(descriptor)) ?? []
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
