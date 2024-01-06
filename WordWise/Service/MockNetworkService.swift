//
//  MockNetworkService.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 1/6/24.
//

import Foundation
import Combine

class MockNetworkService: NetworkServiceProtocol {
    func fetchDefinitionsAndImages(text: String) -> AnyPublisher<CardData, Error> {
        Just(CardData.mock)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<[String], Error> {
        Just(texts.map { "translation of \($0)" })
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func retryFetchingImages(text: String) -> AnyPublisher<[Data], Error> {
        Just([Data]())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
