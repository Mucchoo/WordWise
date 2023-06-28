//
//  Definition+CoreDataProperties.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/20/23.
//
//

import Foundation
import CoreData


extension Definition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Definition> {
        return NSFetchRequest<Definition>(entityName: "Definition")
    }

    @NSManaged public var antonyms: String?
    @NSManaged public var definition: String?
    @NSManaged public var synonyms: String?
    @NSManaged public var example: String?
    @NSManaged public var meaning: NSSet?

}

// MARK: Generated accessors for meaning
extension Definition {

    @objc(addMeaningObject:)
    @NSManaged public func addToMeaning(_ value: Meaning)

    @objc(removeMeaningObject:)
    @NSManaged public func removeFromMeaning(_ value: Meaning)

    @objc(addMeaning:)
    @NSManaged public func addToMeaning(_ values: NSSet)

    @objc(removeMeaning:)
    @NSManaged public func removeFromMeaning(_ values: NSSet)

}

extension Definition : Identifiable {

}
