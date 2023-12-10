//
//  SwiftDataService.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftData
import SwiftUI
import Combine

class SwiftDataService {
    @Environment(\.modelContext) private var context
    private var cancellables = Set<AnyCancellable>()
    let networkService: NetworkService
    let appState: AppState
    
    init(networkService: NetworkService, appState: AppState) {
        self.networkService = networkService
        self.appState = appState
    }

    func retryFetchingImagesIfNeeded() {
        let cardsFailedFetchingImages = appState.cards.filter { $0.retryFetchImages }
        
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
        guard appState.categories.isEmpty else { return }
        let defaultCategoryName = "Category 1"
        let newCategory = CardCategory()
        newCategory.name = defaultCategoryName
        appState.categories.append(newCategory)
    }
    
    private func deleteDuplicatedCategory() {
        let groupedCategories = Dictionary(grouping: appState.categories) { category in
            return category.name ?? ""
        }
        
        let duplicateGroups = groupedCategories.filter { $1.count > 1 }
        guard !duplicateGroups.isEmpty else { return }
        
        for (name, duplicateCategories) in duplicateGroups {
            print("Found \(duplicateCategories.count) duplicates for category named: \(name)")
            
            let categoriesToDelete = duplicateCategories.dropFirst()
            
            for category in categoriesToDelete {
                context.delete(category)
                appState.categories.removeAll { $0 == category }
            }
        }
    }
    
    private func createMissingCategoryIfNeeded() {
        var missingCategoryName = ""
        
        appState.cards.forEach { card in
            if !appState.categories.contains(where: { $0.name == card.category }) {
                missingCategoryName = card.category
            }
        }
        
        guard !missingCategoryName.isEmpty else { return }
        
        let missingCategory = CardCategory()
        missingCategory.name = missingCategoryName
        appState.categories.append(missingCategory)
    }
}
