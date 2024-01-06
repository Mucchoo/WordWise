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
    @Published var categoryTextFieldInput = ""
    @Published var targetCategory = ""
    
    var cards: [Card] {
        let fetchDescriptor = FetchDescriptor<Card>()
        return (try? container.modelContext.fetch(fetchDescriptor)) ?? []
    }
    
    var categories: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: "categories") ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "categories")
        }
    }
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func renameCategory() {
        cards.filter({ $0.category == targetCategory }).forEach { card in
            card.category = categoryTextFieldInput
        }
        
        if let index = categories.firstIndex(of: targetCategory) {
            categories[index] = categoryTextFieldInput
        }
    }
    
    func deleteCategory() {
        guard let category = categories.first(where: { $0 == targetCategory }) else { return }
        categories.removeAll(where: { $0 == category })
    }
}
