//
//  translationViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/24/23.
//

import Combine
import Foundation

struct TranslationRequest: Codable {
    var text: [String]
    var target_lang: String
    var source_lang = "EN"
}

struct TranslationResponse: Codable {
    struct Translation: Codable {
        var detected_source_language: String
        var text: String
    }
    
    var translations: [Translation]
}
