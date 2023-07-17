//
//  MockCardService.swift
//  VocabAITests
//
//  Created by Musa Yazuju on 7/18/23.
//

import Foundation
import Combine
@testable import VocabAI

class MockCardService: CardService {
    var mockCardResponse: CardResponse?
    var fetchError: Error?

    var mockImageUrls: [String]?
    var fetchImagesError: Error?
    
    func fetch(word: String) -> AnyPublisher<CardResponse, Error> {
        if let error = fetchError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockCardResponse {
            return Just(response).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
    
    func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        if let error = fetchImagesError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let urls = mockImageUrls {
            return Just(urls).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
}
