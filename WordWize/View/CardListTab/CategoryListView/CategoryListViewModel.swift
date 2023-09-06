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
        guard let category = container.appState.categories.first(where: { $0.name == targetCategoryName }) else { return }
        
        container.appState.cards.filter({ $0.category == category.name }).forEach { card in
            card.category = categoryNameTextFieldInput
        }
        
        category.name = categoryNameTextFieldInput
        container.coreDataService.saveAndReload()
    }
    
    func deleteCategory() {
        guard let category = container.appState.categories.first(where: { $0.name == targetCategoryName }) else { return }
        container.persistence.viewContext.delete(category)
        container.appState.categories.removeAll(where: { $0.name == category.name })
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", targetCategoryName)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.persistence.viewContext.execute(batchDeleteRequest)
        } catch {
            print("Failed to execute batch delete: \(error)")
        }
        
        container.coreDataService.saveAndReload()
    }
}
