//
//  ImageData+CoreDataProperties.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/21/23.
//
//

import Foundation
import CoreData


extension ImageData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageData> {
        return NSFetchRequest<ImageData>(entityName: "ImageData")
    }

    @NSManaged public var priority: Int64
    @NSManaged public var data: Data?
    @NSManaged public var card: Card?

}

extension ImageData : Identifiable {

}
