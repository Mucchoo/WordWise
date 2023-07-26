//
//  MockCardService.swift
//  WordWizeTests
//
//  Created by Musa Yazuju on 7/18/23.
//

import Foundation
import Combine
@testable import WordWize

class MockCardService: CardService {
    var mockWordDefinition: WordDefinition?
    var fetchError: Error?

    var mockImageUrls: [String]?
    var fetchImagesError: Error?
    
    func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error> {
        if let error = fetchError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockWordDefinition {
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
