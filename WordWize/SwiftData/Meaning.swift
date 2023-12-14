//
//  Meaning.swift
//  WordWize
//
//  Created by Musa Yazici on 11/14/23.
//
//

import Foundation
import SwiftData

@Model final class Meaning {
    @Attribute(.unique) var id:String
    var createdAt: Date = Date()
    var partOfSpeech: String = ""
    var card: Card?
    
    @Relationship(deleteRule: .cascade, inverse: \Definition.meaning) var definitions: [Definition] = []
    
    init() {
        self.id = UUID().uuidString
    }
}
