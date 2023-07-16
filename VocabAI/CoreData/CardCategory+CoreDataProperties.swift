//
//  CardCategory+CoreDataProperties.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/16/23.
//
//

import Foundation
import CoreData


extension CardCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CardCategory> {
        return NSFetchRequest<CardCategory>(entityName: "CardCategory")
    }

    @NSManaged public var name: String?

}

extension CardCategory : Identifiable {

}
