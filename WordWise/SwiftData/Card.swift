//
//  Card.swift
//  WordWise
//
//  Created by Musa Yazici on 11/14/23.
//
//

import UIKit
import SwiftData

@Model final class Card {
    @Attribute(.unique) var id:String
    var category: String = ""
    var lastHardDate: Date?
    var masteryRate: Int16 = 0
    var nextLearningDate: Date = Date()
    var retryFetchImages: Bool = false
    var text: String = ""
    var imageDatas: [Data] = []
    
    @Relationship(inverse: \Meaning.card) var meanings: [Meaning] = []
    @Relationship(inverse: \Phonetic.card) var phonetics: [Phonetic] = []
    
    init() {
        self.id = UUID().uuidString
    }
    
    var isTodayOrBefore: Bool {
        return Calendar.current.isDateInToday(nextLearningDate) || Date() > nextLearningDate
    }
    
    var isUpcoming: Bool {
        return !Calendar.current.isDateInToday(nextLearningDate) && Date() < nextLearningDate
    }
    
    var rate: MasteryRate {
        return MasteryRate(rawValue: masteryRate) ?? .zero
    }
    
    func setCardData(_ cardData: CardData) {
        category = cardData.category
        lastHardDate = cardData.lastHardDate
        masteryRate = cardData.masteryRate
        nextLearningDate = cardData.nextLearningDate
        retryFetchImages = cardData.retryFetchImages
        text = cardData.text
        imageDatas = cardData.imageDatas
        meanings = cardData.meanings
        phonetics = cardData.phonetics
    }
}
