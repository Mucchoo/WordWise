//
//  CategoryListViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWise

class CategoryListViewModelTests: XCTestCase {
    
    var vm: CategoryListViewModel!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = .init(container: .mock())
    }

    override func tearDown() {
        vm.container.modelContainer.deleteAllData()
        vm = nil
        super.tearDown()
    }

    func testRenameCategory() {
        let expectation = XCTestExpectation(description: "Rename category")
        
        let initialCategory = "InitialCategory"
        let newCategory = "NewCategory"
        
        vm.categories.append(initialCategory)
                
        let card = Card()
        card.category = initialCategory
        vm.targetCategory = initialCategory
        vm.categoryTextFieldInput = newCategory
        vm.renameCategory()
        
        XCTAssertEqual(vm.categories.first!, newCategory, "Category should be renamed")
        XCTAssertEqual(card.category, newCategory, "Card category should be updated")
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteCategory() {
        let expectation = XCTestExpectation(description: "Delete category")
        
        let initialCategory = "InitialCategory"
        vm.categories.append(initialCategory)
        
        let card = Card()
        card.category = initialCategory
        vm.targetCategory = initialCategory
        vm.deleteCategory()
        
        XCTAssertTrue(vm.categories.isEmpty, "Category should be removed")
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
}
