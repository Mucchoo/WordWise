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
    @EnvironmentObject var dataViewModel: DataViewModel

    @Published var showingRenameAlert = false
    @Published var showingDeleteAlert = false
    @Published var categoryNameTextFieldInput = ""
    @Published var targetCategoryName = ""
    
    func renameCategory() {
        guard let category = dataViewModel.categories.first(where: { $0.name == targetCategoryName }) else { return }
        
        DispatchQueue.main.async { [self] in
            dataViewModel.cards.filter({ $0.category == category.name }).forEach { card in
                card.category = categoryNameTextFieldInput
            }
            
            category.name = categoryNameTextFieldInput
            dataViewModel.saveAndReload()
        }
    }
    
    func deleteCategory() {
        guard let category = dataViewModel.categories.first(where: { $0.name == targetCategoryName }) else { return }
        dataViewModel.viewContext.delete(category)
        dataViewModel.categories.removeAll(where: { $0.name == category.name })
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", targetCategoryName)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try dataViewModel.viewContext.execute(batchDeleteRequest)
        } catch {
            print("Failed to execute batch delete: \(error)")
        }
        
        dataViewModel.saveAndReload()
    }
}
