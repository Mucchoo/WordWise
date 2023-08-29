//
//  MockCardService.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import Foundation
import Combine
import CoreData

class MockNetworkService: NetworkService {
    func fetchAndPopulateCard(word: String, card: Card, context: NSManagedObjectContext, onFetched: @escaping () -> Void) -> AnyPublisher<Card, Error> {
        return Future<Card, Error> { promise in
            print("Mocking card for \(word)")
            card.setMockData(context: context)
            onFetched()
            promise(.success(card))
        }
        .eraseToAnyPublisher()
    }
    
    func retryFetchingImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let imageData = ImageData(context: context)
            imageData.data = Data([0x11, 0x22, 0x33])
            imageData.priority = 0
            imageData.retryFlag = false
            card.addToImageDatas(imageData)
        }
        
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error> {
        let sampleDefinition = WordDefinition(
            word: "example",
            phonetic: "ɪgˈzam.pəl",
            phonetics: [],
            origin: "Latin exemplum",
            meanings: [
                .init(partOfSpeech: "noun", definitions: [
                    .init(definition: "A representative form or pattern.", example: nil, synonyms: nil, antonyms: nil)
                ])
            ]
        )
        return Just(sampleDefinition)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        let sampleImageURL = "https://www.example.com/sample.jpg"
        return Just([sampleImageURL])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<TranslationResponse, Error> {
        let sampleTranslation = TranslationResponse(
            translations: texts.map { TranslationResponse.Translation(detected_source_language: "en", text: "\($0) in another language") }
        )
        return Just(sampleTranslation)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
