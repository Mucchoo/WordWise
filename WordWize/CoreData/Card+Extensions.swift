//
//  Card+Extensions.swift
//  WordWize
//
//  Created by Musa Yazici on 9/10/23.
//

import CoreData
import UIKit

extension Card {
    public var unwrappedText: String {
        text ?? "Unknown"
    }
    
    public var phoneticsArray: [Phonetic] {
        let phoneticSet = phonetics as? Set<Phonetic> ?? []
        
        return phoneticSet.sorted {
            ($0.text ?? "") < ($1.text ?? "")
        }
    }
    
    public var meaningsArray: [Meaning] {
        let meaningSet = meanings as? Set<Meaning> ?? []
        
        return meaningSet.sorted {
            $0.createdAt ?? Date() < $1.createdAt ?? Date()
        }
    }
    
    public var imageDatasArray: [ImageData] {
        let urlSet = imageDatas as? Set<ImageData> ?? []
        
        return urlSet.sorted {
            $0.priority < $1.priority
        }
    }
    
    public var isTodayOrBefore: Bool {
        guard let nextLearningDate = nextLearningDate else {
            return false
        }
        return Calendar.current.isDateInToday(nextLearningDate) || Date() > nextLearningDate
    }
    
    public var isUpcoming: Bool {
        guard let nextLearningDate = nextLearningDate else {
            return false
        }
        return !Calendar.current.isDateInToday(nextLearningDate) && Date() < nextLearningDate
    }
    
    public var rate: MasteryRate {
        return MasteryRate(rawValue: masteryRate) ?? .zero
    }

    public func setMockData(context: NSManagedObjectContext) {
        let newMeaning1 = Meaning(context: context)
        newMeaning1.partOfSpeech = "Noun"
        newMeaning1.createdAt = Date()
        self.addToMeanings(newMeaning1)
        
        let newMeaning2 = Meaning(context: context)
        newMeaning2.partOfSpeech = "Noun"
        newMeaning2.createdAt = Date()
        self.addToMeanings(newMeaning2)
        
        let newDefinition = Definition(context: context)
        newDefinition.definition = "A mock definition"
        newDefinition.example = "An example using the mock definition."
        newDefinition.antonyms = "opposite"
        newDefinition.synonyms = "similar"
        newDefinition.createdAt = Date()
        newMeaning1.addToDefinitions(newDefinition)

        let newPhonetic = Phonetic(context: context)
        newPhonetic.text = "/mɒk/"
        self.addToPhonetics(newPhonetic)
                
        let invalidImageData = ImageData(context: context)
        invalidImageData.data = Data()
        invalidImageData.priority = 0
        self.addToImageDatas(invalidImageData)
        
        let validImageData = ImageData(context: context)
        validImageData.data = UIImage(systemName: "circle")?.pngData()
        validImageData.priority = 1
        self.addToImageDatas(validImageData)
    }
}
