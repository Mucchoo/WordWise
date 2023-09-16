//
//  CoreDataService.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import CoreData
import SwiftUI
import Combine

class CoreDataService {
    private var cancellables = Set<AnyCancellable>()
    let persistence: Persistence
    let networkService: NetworkService
    let appState: AppState
    
    init(persistence: Persistence, networkService: NetworkService, appState: AppState) {
        self.persistence = persistence
        self.networkService = networkService
        self.appState = appState
        loadData()
    }

    func loadData() {
        fetchCategories()
        fetchCards()
    }

    private func fetchCards() {
        let cardFetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        do {
            let fetchedCards = try persistence.viewContext.fetch(cardFetchRequest)
            DispatchQueue.main.async {
                self.appState.cards = fetchedCards
                self.appState.isDataLoaded = true
                self.createMissingCategoryIfNeeded()
            }
        } catch let error as NSError {
            print("Could not fetch Cards. \(error), \(error.userInfo)")
        }
    }

    private func fetchCategories() {
        let categoryFetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        do {
            let fetchedCategories = try persistence.viewContext.fetch(categoryFetchRequest)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.appState.categories = fetchedCategories
                if self.appState.categories.isEmpty {
                    self.addDefaultCategory()
                }
                self.deleteDuplicatedCategory()
            }
        } catch let error as NSError {
            print("Could not fetch Categories. \(error), \(error.userInfo)")
        }
    }

    func retryFetchingImagesIfNeeded() {
        let cardsFailedFetchingImages = appState.cards.filter { $0.retryFetchImages }
        
        let fetchPublishers = cardsFailedFetchingImages.publisher
            .flatMap(maxPublishers: .max(10)) { card -> AnyPublisher<Void, Never> in
                return self.networkService.retryFetchingImages(card: card, context: self.persistence.viewContext)
                    .catch { _ in Empty<Void, Never>() }
                    .eraseToAnyPublisher()
            }
        
        fetchPublishers
            .sink(receiveCompletion: { _ in
                self.persistence.saveContext()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func saveAndReload() {
        persistence.saveContext()
        loadData()
    }
    
    func addDefaultCategoryIfNeeded(completion: (() -> ())? = nil) {
        if appState.categories.isEmpty {
            addDefaultCategory(completion: completion)
        }
    }

    private func addDefaultCategory(completion: (() -> ())? = nil) {
        let defaultCategoryName = "Category 1"
        let fetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", defaultCategoryName)

        do {
            let existingCategories = try persistence.viewContext.fetch(fetchRequest)
            guard existingCategories.isEmpty else { return }
            
            let newCategory = CardCategory(context: persistence.viewContext)
            newCategory.name = defaultCategoryName
            appState.categories.append(newCategory)
            
            persistence.saveContext()
            completion?()
            
        } catch let error {
            print("Failed to fetch categories: \(error.localizedDescription)")
        }
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
                persistence.viewContext.delete(category)
                appState.categories.removeAll { $0 == category }
            }
        }
        
        saveAndReload()
    }
    
    private func createMissingCategoryIfNeeded() {
        var missingCategoryName = ""
        
        appState.cards.forEach { card in
            if !appState.categories.contains(where: { $0.name == card.category }) {
                missingCategoryName = card.category ?? ""
            }
        }
        
        guard !missingCategoryName.isEmpty else { return }
        
        let missingCategory = CardCategory(context: persistence.viewContext)
        missingCategory.name = missingCategoryName
        appState.categories.append(missingCategory)
        saveAndReload()
    }
}
