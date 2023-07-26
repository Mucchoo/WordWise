//
//  CardService.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/26/23.
//

import Foundation
import Combine

protocol CardService {
    func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error>
    func fetchImages(word: String) -> AnyPublisher<[String], Error>
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<TranslationResponse, Error>
}
