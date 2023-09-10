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
    func fetchDefinitionsAndImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Card, Error> {
        return Future<Card, Error> { promise in
            print("Mocking card for \(card.text ?? "nil")")
            card.setMockData(context: context)
            promise(.success(card))
        }
        .eraseToAnyPublisher()
    }
    
    func retryFetchingImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let imageData = ImageData(context: context)
            imageData.data = Data([0x11, 0x22, 0x33])
            imageData.priority = 0
            card.addToImageDatas(imageData)
        }
        
        return Just(())
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
