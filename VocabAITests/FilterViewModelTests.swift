//
//  FilterViewModelTests.swift
//  VocabAITests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest
@testable import VocabAI

final class FilterViewModelTests: XCTestCase {

    var userDefaults: UserDefaults!
    var filterViewModel: FilterViewModel!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)

        filterViewModel = FilterViewModel(userDefaults: userDefaults)
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        filterViewModel = nil
    }

    func testSelectedCategoriesStorage() throws {
        let testCategories = ["Test1", "Test2", "Test3"]
        
        filterViewModel.selectedCategories = testCategories

        if let data = userDefaults.data(forKey: "selectedCategories"),
           let loadedCategories = try? JSONDecoder().decode([String].self, from: data) {
            XCTAssertEqual(loadedCategories, testCategories)
        } else {
            XCTFail("Failed to load selected categories from UserDefaults.")
        }
    }

    func testFilterStatusStorage() throws {
        let testStatus = [Int16](1...3)

        filterViewModel.filterStatus = testStatus

        if let data = userDefaults.data(forKey: "filterStatus"),
           let loadedStatus = try? JSONDecoder().decode([Int16].self, from: data) {
            XCTAssertEqual(loadedStatus, testStatus)
        } else {
            XCTFail("Failed to load filter status from UserDefaults.")
        }
    }
}
