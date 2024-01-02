//
//  CategoryListViewModel.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine
import SwiftData

class CategoryListViewModel: ObservableObject {
    let container: DIContainer

    @Published var showingRenameAlert = false
    @Published var showingDeleteAlert = false
    @Published var categoryNameTextFieldInput = ""
    @Published var targetCategoryName = ""
    
    var cards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        return (try? container.modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    var categories: [CardCategory] {
        let fetchDescriptor = FetchDescriptor<CardCategory>()
        return (try? container.modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func renameCategory() {
        cards.filter({ $0.category == targetCategoryName }).forEach { card in
            card.category = categoryNameTextFieldInput
        }
        
        categories.first(where: { $0.name == targetCategoryName })?.name = categoryNameTextFieldInput
    }
    
    func deleteCategory() {
        guard let category = categories.first(where: { $0.name == targetCategoryName }) else { return }
        container.modelContext.delete(category)
    }
}
