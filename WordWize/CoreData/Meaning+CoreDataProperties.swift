//
//  Meaning+CoreDataProperties.swift
//  WordWize
//
//  Created by Musa Yazuju on 6/20/23.
//
//

import Foundation
import CoreData


extension Meaning {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meaning> {
        return NSFetchRequest<Meaning>(entityName: "Meaning")
    }

    @NSManaged public var partOfSpeech: String?
    @NSManaged public var card: Card?
    @NSManaged public var definitions: NSSet?

    public var definitionsArray: [Definition] {
        let definitionSet = definitions as? Set<Definition> ?? []
        
        return definitionSet.sorted {
            $0.id < $1.id
        }
    }
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
