//
//  Word.swift
//  Flashcard
//
//  Created by Musa Yazuju on 6/14/23.
//

import Foundation

struct Word: Identifiable {
    let id = UUID()
    let text: String
    let status: WordStatus
}

enum WordStatus {
    case learned, learning, new
}

struct Mock {
    static let englishWords: [String] = [
        "ability", "absence", "academy", "accident", "accuracy", "achieve",
        "acquire", "activity", "actually", "addition", "address", "adequate",
        "adoption", "advanced", "adventure", "advisory", "advocate", "aerospace",
        "agriculture", "airline", "allegation", "allegedly", "ambassador", "amendment",
        "analytical", "animation", "apologize", "appliance", "applicable", "appointment",
        "appreciate", "architect", "artificial", "assessment", "assignment", "assistance",
        "associate", "atmosphere", "attendance", "authority", "automation", "automotive",
        "awareness", "bandwidth", "bankruptcy", "benchmark", "biography", "biotechnology",
        "boulevard", "breakfast", "broadcast", "calculator", "campaign", "capability",
        "capitalism", "celebrity", "challenge", "character", "chemistry", "chocolate",
        "classroom", "collective", "commission", "commitment", "comparison", "compensation",
        "compliance", "composite", "concentrate", "conclusion", "confidence", "confidential",
        "consequence", "conservative", "continuous", "contribute", "convenience", "coordinate",
        "corporation", "correlation", "credibility", "curriculum", "decoration", "democratic",
        "department", "dependency", "depression", "descendant", "description", "designer",
        "developer", "development", "difference", "difficulty", "dimension", "discipline",
        "diversity", "education", "efficiency", "electronic", "emergency", "employment"
    ]
    
    static let words: [Word] = {
        var words: [Word] = []

        for i in 0..<20 {
            words.append(Word(text: englishWords[i], status: .learned))
        }
        for i in 20..<50 {
            words.append(Word(text: englishWords[i], status: .learning))
        }
        for i in 50..<100 {
            words.append(Word(text: englishWords[i], status: .new))
        }

        return words
    }()
}

