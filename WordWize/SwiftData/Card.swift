//
//  Card.swift
//  WordWize
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
    
    @Relationship(inverse: \ImageData.card) var imageDatas: [ImageData] = []
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

    func setMockData() {
        let newMeaning1 = Meaning()
        newMeaning1.partOfSpeech = "Noun"
        newMeaning1.createdAt = Date()
        
        let newMeaning2 = Meaning()
        newMeaning2.partOfSpeech = "Noun"
        newMeaning2.createdAt = Date()
        
        let newDefinition = Definition()
        newDefinition.definition = "A mock definition"
        newDefinition.example = "An example using the mock definition."
        newDefinition.antonyms = "opposite"
        newDefinition.synonyms = "similar"
        newDefinition.createdAt = Date()

        let newPhonetic = Phonetic()
        newPhonetic.text = "/mɒk/"
                
        let invalidImageData = ImageData()
        invalidImageData.data = Data()
        invalidImageData.priority = 0
        
        let validImageData = ImageData()
        validImageData.data = UIImage(systemName: "circle")?.pngData()
        validImageData.priority = 1
    }
}
