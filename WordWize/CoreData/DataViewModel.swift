//
//  DataViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import CoreData
import SwiftUI
import Combine

class DataViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var categories: [CardCategory] = []
    @Published var studyingCards: [Card] = []
    @Published var todaysCards: [Card] = []
    @Published var upcomingCards: [Card] = []
    @Published var isDataLoaded = false
    
    private var isAddingDefaultCategory = false
    var cancellables = Set<AnyCancellable>()
    let cardService: CardService
    let persistence: Persistence
    let viewContext: NSManagedObjectContext
    
    init(cardService: CardService, persistence: Persistence) {
        self.cardService = cardService
        self.persistence = persistence
        self.viewContext = persistence.viewContext
        loadData()
    }

    func loadData() {
        fetchCards()
        fetchCategories()
        isDataLoaded = true
    }

    private func fetchCards() {
        let cardFetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        do {
            let fetchedCards = try viewContext.fetch(cardFetchRequest)
            DispatchQueue.main.async {
                self.cards = fetchedCards
            }
        } catch let error as NSError {
            print("Could not fetch Cards. \(error), \(error.userInfo)")
        }
    }

    private func fetchCategories() {
        let categoryFetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        do {
            let fetchedCategories = try viewContext.fetch(categoryFetchRequest)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.categories = fetchedCategories
                if self.categories.isEmpty {
                    self.addDefaultCategory()
                }
                self.deleteDuplicatedCategory()
            }
        } catch let error as NSError {
            print("Could not fetch Categories. \(error), \(error.userInfo)")
        }
    }

    func retryFetchingImages() {
        let cardsFailedFetchingImages = cards.filter { $0.shouldRetryFetchingImages }
        
        let fetchPublishers = cardsFailedFetchingImages.publisher
            .flatMap(maxPublishers: .max(10)) { card -> AnyPublisher<Void, Never> in
                return self.cardService.retryFetchingImages(card: card, context: self.viewContext)
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
        if categories.isEmpty {
            addDefaultCategory(completion: completion)
        }
    }

    private func addDefaultCategory(completion: (() -> ())? = nil) {
        let defaultCategoryName = "Category 1"
        let fetchRequest: NSFetchRequest<CardCategory> = CardCategory.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", defaultCategoryName)

        do {
            let existingCategories = try viewContext.fetch(fetchRequest)
            guard existingCategories.isEmpty else { return }
            
            let newCategory = CardCategory(context: viewContext)
            newCategory.name = defaultCategoryName
            categories.append(newCategory)
            
            persistence.saveContext()
            completion?()
            
        } catch let error {
            print("Failed to fetch categories: \(error.localizedDescription)")
        }
    }
    
    private func deleteDuplicatedCategory() {
        let groupedCategories = Dictionary(grouping: categories) { (category: CardCategory) in
            return category.name ?? ""
        }
        
        let duplicateGroups = groupedCategories.filter { $1.count > 1 }
        
        for (name, duplicateCategories) in duplicateGroups {
            print("Found \(duplicateCategories.count) duplicates for category named: \(name)")
            
            let categoriesToDelete = duplicateCategories.dropFirst()
            
            for category in categoriesToDelete {
                viewContext.delete(category)
                categories.removeAll { $0 == category }
            }
        }
        
        saveAndReload()
    }
}
