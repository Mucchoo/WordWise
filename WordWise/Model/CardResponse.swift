//
//  WordDefinition.swift
//  WordWise
//
//  Created by Musa Yazuju on 6/21/23.
//

import Foundation

struct WordDefinition: Codable, Identifiable {
    let id = UUID()
    let word: String
    let phonetic: String?
    let phonetics: [Phonetic]?
    let origin: String?
    let meanings: [Meaning]?

    private enum CodingKeys: String, CodingKey {
        case word, phonetic, phonetics, origin, meanings
    }

    struct Phonetic: Codable {
        let text: String?
    }

    struct Meaning: Codable, Identifiable {
        let id = UUID()
        let partOfSpeech: String?
        let definitions: [Definition]?

        private enum CodingKeys: String, CodingKey {
            case partOfSpeech, definitions
        }

        struct Definition: Codable, Identifiable {
            let id = UUID()
            let definition: String?
            let example: String?
            let synonyms: [String]?
            let antonyms: [String]?

            private enum CodingKeys: String, CodingKey {
                case definition, example, synonyms, antonyms
            }
        }
    }
}
