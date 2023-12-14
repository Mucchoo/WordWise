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
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func renameCategory() {
        container.appState.cards.filter({ $0.category == targetCategoryName }).forEach { card in
            card.category = categoryNameTextFieldInput
        }
        
        container.appState.categories.first(where: { $0.name == targetCategoryName })?.name = categoryNameTextFieldInput
    }
    
    func deleteCategory() {
        guard let category = container.appState.categories.first(where: { $0.name == targetCategoryName }) else { return }
        container.appState.categories.removeAll(where: { $0.name == category.name })
    }
}
