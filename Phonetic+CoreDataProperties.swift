//
//  Phonetic+CoreDataProperties.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/19/23.
//
//

import Foundation
import CoreData


extension Phonetic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Phonetic> {
        return NSFetchRequest<Phonetic>(entityName: "Phonetic")
    }

    @NSManaged public var text: String?
    @NSManaged public var audio: String?
    @NSManaged public var card: Card?
    
    public var unwrappedText: String {
        text ?? "Unknown Text"
    }

}

extension Phonetic : Identifiable {

}
