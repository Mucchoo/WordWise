//
//  Definition.swift
//  WordWise
//
//  Created by Musa Yazici on 11/14/23.
//
//

import Foundation
import SwiftData

@Model final class Definition {
    @Attribute(.unique) var id:String
    var antonyms: String?
    var createdAt: Date?
    var definition: String = ""
    var example: String?
    var synonyms: String?
    var translatedDefinition: String = ""
    var meaning: Meaning?
    
    init() {
        self.id = UUID().uuidString
    }
    
    static var mock: Definition {
        let definition = Definition()
        definition.definition = "A mock definition"
        definition.example = "An example using the mock definition."
        definition.antonyms = "opposite"
        definition.synonyms = "similar"
        definition.createdAt = Date()
        return definition
    }
}
