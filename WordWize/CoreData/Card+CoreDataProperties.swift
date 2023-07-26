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
    @NSManaged public var failedTimes: Int64
    @NSManaged public var id: UUID?
    @NSManaged public var status: Int16
    @NSManaged public var text: String?
    @NSManaged public var imageUrls: NSSet?
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
    
    public var imageUrlsArray: [ImageUrl] {
        let urlSet = imageUrls as? Set<ImageUrl> ?? []
        
        return urlSet.sorted {
            $0.priority < $1.priority
        }
    }
}

// MARK: Generated accessors for imageUrls
extension Card {

    @objc(addImageUrlsObject:)
    @NSManaged public func addToImageUrls(_ value: ImageUrl)

    @objc(removeImageUrlsObject:)
    @NSManaged public func removeFromImageUrls(_ value: ImageUrl)

    @objc(addImageUrls:)
    @NSManaged public func addToImageUrls(_ values: NSSet)

    @objc(removeImageUrls:)
    @NSManaged public func removeFromImageUrls(_ values: NSSet)

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
