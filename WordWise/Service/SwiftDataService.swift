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
    let networkService: NetworkService
    let context: ModelContext
    
    var cards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        return (try? context.fetch(fetchDescriptor)) ?? []
    }
    
    var categories: [CardCategory] {
        let fetchDescriptor = FetchDescriptor<CardCategory>()
        return (try? context.fetch(fetchDescriptor)) ?? []
    }
    
    init(networkService: NetworkService, context: ModelContext) {
        self.networkService = networkService
        self.context = context
    }

    func retryFetchingImagesIfNeeded() {
        let cardsFailedFetchingImages = cards.filter { $0.retryFetchImages }
        
        let fetchPublishers = cardsFailedFetchingImages.publisher
            .flatMap(maxPublishers: .max(10)) { card -> AnyPublisher<Void, Never> in
                return self.networkService.retryFetchingImages(card: card)
                    .catch { _ in Empty<Void, Never>() }
                    .eraseToAnyPublisher()
            }
        
        fetchPublishers
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func addDefaultCategoryIfNeeded() {
        guard categories.isEmpty else { return }
        let defaultCategoryName = "Category 1"
        let newCategory = CardCategory()
        context.insert(newCategory)
        newCategory.name = defaultCategoryName
    }
    
    private func deleteDuplicatedCategory() {
        let groupedCategories = Dictionary(grouping: categories) { category in
            return category.name ?? ""
        }
        
        let duplicateGroups = groupedCategories.filter { $1.count > 1 }
        guard !duplicateGroups.isEmpty else { return }
        
        for (name, duplicateCategories) in duplicateGroups {
            print("Found \(duplicateCategories.count) duplicates for category named: \(name)")
            
            let categoriesToDelete = duplicateCategories.dropFirst()
            
            for category in categoriesToDelete {
                context.delete(category)
            }
        }
    }
    
    private func createMissingCategoryIfNeeded() {
        var missingCategoryName = ""
        
        cards.forEach { card in
            if !categories.contains(where: { $0.name == card.category }) {
                missingCategoryName = card.category
            }
        }
        
        guard !missingCategoryName.isEmpty else { return }
        
        let missingCategory = CardCategory()
        context.insert(missingCategory)
        missingCategory.name = missingCategoryName
    }
}
