//
//  Meaning+CoreDataProperties.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/19/23.
//
//

import Foundation
import CoreData


extension Meaning {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meaning> {
        return NSFetchRequest<Meaning>(entityName: "Meaning")
    }

    @NSManaged public var id: String?
    @NSManaged public var partOfSpeech: String?
    @NSManaged public var definitions: NSSet?
    @NSManaged public var card: Card?

}

// MARK: Generated accessors for definitions
extension Meaning {

    @objc(addDefinitionsObject:)
    @NSManaged public func addToDefinitions(_ value: Definition)

    @objc(removeDefinitionsObject:)
    @NSManaged public func removeFromDefinitions(_ value: Definition)

    @objc(addDefinitions:)
    @NSManaged public func addToDefinitions(_ values: NSSet)

    @objc(removeDefinitions:)
    @NSManaged public func removeFromDefinitions(_ values: NSSet)

}

extension Meaning : Identifiable {

}
