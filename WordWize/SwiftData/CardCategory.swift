//
//  CardCategory.swift
//  WordWize
//
//  Created by Musa Yazici on 11/14/23.
//
//

import Foundation
import SwiftData

@Model class CardCategory {
    @Attribute(.unique) var id:String
    var name: String?
    
    init() {
        self.id = UUID().uuidString
    }
}
