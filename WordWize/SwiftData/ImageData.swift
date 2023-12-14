//
//  ImageData.swift
//  WordWize
//
//  Created by Musa Yazici on 11/14/23.
//
//

import Foundation
import SwiftData

@Model final class ImageData {
    @Attribute(.unique) var id:String
    var data: Data?
    var priority: Int = 0
    var card: Card?
    
    init() {
        self.id = UUID().uuidString
    }
}
