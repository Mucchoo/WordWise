//
//  SwiftDataService.swift
//  WordWise
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftData
import SwiftUI
import Combine

class SwiftDataService {
    private var cancellables = Set<AnyCancellable>()
    let networkService: NetworkServiceProtocol
    let context: ModelContext
    
    var cards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        return (try? context.fetch(fetchDescriptor)) ?? []
    }
    
    var categories: [String] {
        return UserDefaults.standard.stringArray(forKey: "categories") ?? []
    }
    
    init(networkService: NetworkServiceProtocol, context: ModelContext) {
        self.networkService = networkService
        self.context = context
    }

    func retryFetchingImagesIfNeeded() {
        let cardsToRetry = cards.filter { $0.retryFetchImages }
        
        let fetchPublishers = cardsToRetry.publisher
            .flatMap(maxPublishers: .max(10)) { card -> AnyPublisher<[Data], Never> in
                return self.networkService.retryFetchingImages(text: card.text)
                    .handleEvents(receiveOutput: { datas in
                        card.imageDatas = datas
                    })
                    .catch { _ in Empty<[Data], Never>() }
                    .eraseToAnyPublisher()
            }
        
        fetchPublishers
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func addDefaultCategoryIfNeeded() {
        guard categories.isEmpty else { return }
        let defaultCategory = "Category 1"
        
        var categories = UserDefaults.standard.stringArray(forKey: "categories") ?? []
        categories.append(defaultCategory)
        UserDefaults.standard.set(categories, forKey: "categories")
    }
}
