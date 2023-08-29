//
//  NetworkService.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/26/23.
//

import Foundation
import Combine
import CoreData

protocol NetworkService {
    func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error>
    func fetchImages(word: String) -> AnyPublisher<[String], Error>
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<TranslationResponse, Error>
    func fetchAndPopulateCard(word: String, card: Card, context: NSManagedObjectContext, onFetched: @escaping () -> Void) -> AnyPublisher<Card, Error>
    func retryFetchingImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Void, Error>
}
