//
//  Card+CoreDataProperties.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/16/23.
//
//

import Foundation
import CoreData

extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var category: String?
    @NSManaged public var id: UUID?
    @NSManaged public var lastHardDate: Date?
    @NSManaged public var masteryRate: Int16
    @NSManaged public var nextLearningDate: Date?
    @NSManaged public var text: String?
    @NSManaged public var imageDatas: NSSet?
    @NSManaged public var meanings: NSSet?
    @NSManaged public var phonetics: NSSet?
    
    public var unwrappedText: String {
        text ?? "Unknown"
    }
    
    public var phoneticsArray: [Phonetic] {
        let phoneticSet = phonetics as? Set<Phonetic> ?? []
        
        return phoneticSet.sorted {
            $0.unwrappedText < $1.unwrappedText
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
    
    public var shouldRetryFetchingImages: Bool {
        if let imageDatas = self.imageDatas as? Set<ImageData> {
            return imageDatas.contains { (imageData: ImageData) in
                return imageData.retryFlag
            }
        }
        return false
    }

}

// MARK: Generated accessors for imageData
extension Card {

    @objc(addImageDatasObject:)
    @NSManaged public func addToImageDatas(_ value: ImageData)

    @objc(removeImageDatasObject:)
    @NSManaged public func removeFromImageDatas(_ value: ImageData)

    @objc(addImageDatas:)
    @NSManaged public func addToImageDatas(_ values: NSSet)

    @objc(removeImageDatas:)
    @NSManaged public func removeFromImageDatas(_ values: NSSet)

}

// MARK: Generated accessors for meanings
extension Card {

    @objc(addMeaningsObject:)
    @NSManaged public func addToMeanings(_ value: Meaning)

    @objc(removeMeaningsObject:)
    @NSManaged public func removeFromMeanings(_ value: Meaning)

    @objc(addMeanings:)
    @NSManaged public func addToMeanings(_ values: NSSet)

    @objc(removeMeanings:)
    @NSManaged public func removeFromMeanings(_ values: NSSet)

}

// MARK: Generated accessors for phonetics
extension Card {

    @objc(addPhoneticsObject:)
    @NSManaged public func addToPhonetics(_ value: Phonetic)

    @objc(removePhoneticsObject:)
    @NSManaged public func removeFromPhonetics(_ value: Phonetic)

    @objc(addPhonetics:)
    @NSManaged public func addToPhonetics(_ values: NSSet)

    @objc(removePhonetics:)
    @NSManaged public func removeFromPhonetics(_ values: NSSet)

}

extension Card : Identifiable {

}
