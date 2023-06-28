//
//  Phonetic+CoreDataProperties.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 6/25/23.
//
//

import Foundation
import CoreData


extension Phonetic {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Phonetic> {
        return NSFetchRequest<Phonetic>(entityName: "Phonetic")
    }

    @NSManaged public var audio: String?
    @NSManaged public var text: String?
    @NSManaged public var downloadedAudioUrlString: String?
    @NSManaged public var card: Card?
    
    public var unwrappedText: String {
        text ?? "Unknown Text"
    }
}

extension Phonetic : Identifiable {

}
