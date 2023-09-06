//
//  CategoryListViewModelTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWize

class CategoryListViewModelTests: XCTestCase {
    
    var vm: CategoryListViewModel!
    
    override func setUp() {
        super.setUp()
        vm = .init(container: .mock())
    }

    override func tearDown() {
        vm = nil
        super.tearDown()
    }

    func testRenameCategory() {
        let expectation = XCTestExpectation(description: "Rename category")
        
        let initialCategoryName = "InitialCategory"
        let newCategoryName = "NewCategory"
        
        let category = CardCategory(context: vm.container.persistence.viewContext)
        category.name = initialCategoryName
        vm.container.appState.categories = [category]
        
        let card = Card(context: vm.container.persistence.viewContext)
        card.category = initialCategoryName
        vm.container.appState.cards = [card]
        vm.targetCategoryName = initialCategoryName
        vm.categoryNameTextFieldInput = newCategoryName
        vm.renameCategory()
        
        XCTAssertEqual(category.name, newCategoryName, "Category should be renamed")
        XCTAssertEqual(card.category, newCategoryName, "Card category should be updated")
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testDeleteCategory() {
        let expectation = XCTestExpectation(description: "Delete category")
        
        let initialCategoryName = "InitialCategory"
        
        let category = CardCategory(context: vm.container.persistence.viewContext)
        category.name = initialCategoryName
        vm.container.appState.categories = [category]
        
        let card = Card(context: vm.container.persistence.viewContext)
        card.category = initialCategoryName
        vm.container.appState.cards = [card]
        vm.targetCategoryName = initialCategoryName
        vm.deleteCategory()
        
        XCTAssertTrue(vm.container.appState.categories.isEmpty, "Category should be removed")
        expectation.fulfill()
        wait(for: [expectation], timeout: 3.0)
    }
}
