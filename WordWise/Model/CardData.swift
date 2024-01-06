//
//  CardData.swift
//  WordWise
//
//  Created by Musa Yazici on 1/6/24.
//

import Foundation
import UIKit

class CardData {
    var id: String
    var category: String = ""
    var lastHardDate: Date?
    var masteryRate: Int16 = 0
    var nextLearningDate: Date = Date()
    var retryFetchImages: Bool = false
    var text: String = ""
    var imageDatas: [Data] = []
    
    var meanings: [Meaning] = []
    var phonetics: [Phonetic] = []
    
    init() {
        self.id = UUID().uuidString
    }
    
    static var mock: CardData {
        let cardData = CardData()
        cardData.meanings.append(Meaning.mock)
        cardData.meanings.append(Meaning.mock)
        cardData.phonetics.append(Phonetic.mock)
        cardData.phonetics.append(Phonetic.mock)
        
        let invalidImageData = Data()
        let validImageData = UIImage(systemName: "circle")?.pngData() ?? Data()
        
        cardData.imageDatas.append(invalidImageData)
        cardData.imageDatas.append(validImageData)
        
        return cardData
    }
}
