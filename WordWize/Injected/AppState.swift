//
//  AppState.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/28/23.
//

import Foundation

class AppState: ObservableObject {
    @Published var cards: [Card] = []
    @Published var categories: [CardCategory] = []
    @Published var studyingCards: [Card] = []
    @Published var todaysCards: [Card] = []
    @Published var upcomingCards: [Card] = []
    @Published var isAddingDefaultCategory = false
}
