//
//  ImageUrl+CoreDataProperties.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/16/23.
//
//

import Foundation
import CoreData


extension ImageUrl {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageUrl> {
        return NSFetchRequest<ImageUrl>(entityName: "ImageUrl")
    }

    @NSManaged public var priority: Int64
    @NSManaged public var urlString: String?
    @NSManaged public var card: Card?

}

extension ImageUrl : Identifiable {

}
