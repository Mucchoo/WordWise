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
    var createdAt: Date = Date()
    var partOfSpeech: String = ""
    var definitions: [Definition] = []
    var card: Card?
    
    init() {}
}
