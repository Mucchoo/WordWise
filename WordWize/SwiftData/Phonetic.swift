//
//  Phonetic.swift
//  WordWize
//
//  Created by Musa Yazici on 11/14/23.
//
//

import Foundation
import SwiftData

@Model final class Phonetic {
    @Attribute(.unique) var id:String
    var text: String = ""
    var card: Card?
    
    init() {
        self.id = UUID().uuidString
    }
}
