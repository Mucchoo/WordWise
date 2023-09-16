//
//  CategoryListViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine
import CoreData

class CategoryListViewModel: ObservableObject {
    let container: DIContainer

    @Published var showingRenameAlert = false
    @Published var showingDeleteAlert = false
    @Published var categoryNameTextFieldInput = ""
    @Published var targetCategoryName = ""
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func renameCategory() {
        container.appState.cards.filter({ $0.category == targetCategoryName }).forEach { card in
            card.category = categoryNameTextFieldInput
        }
        
        container.appState.categories.first(where: { $0.name == targetCategoryName })?.name = categoryNameTextFieldInput
        container.coreDataService.saveAndReload()
    }
    
    func deleteCategory() {
        guard let category = container.appState.categories.first(where: { $0.name == targetCategoryName }) else { return }
        
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", targetCategoryName)
        
        do {
            let cardsToDelete = try container.persistence.viewContext.fetch(fetchRequest)
            
            for card in cardsToDelete {
                container.persistence.viewContext.delete(card)
            }
        } catch {
            print("Failed to fetch cards for deletion: \(error)")
        }
        
        container.persistence.viewContext.delete(category)
        container.appState.categories.removeAll(where: { $0.name == category.name })
        container.coreDataService.saveAndReload()
    }
}
