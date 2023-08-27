//
//  CategoryListViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/27/23.
//

import SwiftUI
import Combine

class CategoryListViewModel: ObservableObject {
    @EnvironmentObject var dataViewModel: DataViewModel

    @Published var showingRenameAlert = false
    @Published var showingDeleteAlert = false
    @Published var categoryNameTextFieldInput = ""
    @Published var targetCategoryName = ""
    
    func renameCategory() {
        dataViewModel.renameCategory(before: targetCategoryName, after: categoryNameTextFieldInput)
    }
    
    func deleteCategory() {
        dataViewModel.deleteCategoryAndItsCards(name: targetCategoryName)
    }
}
