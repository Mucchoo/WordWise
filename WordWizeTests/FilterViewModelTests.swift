//
//  FilterViewModelTests.swift
//  WordWizeTests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest
@testable import WordWize

final class FilterViewModelTests: XCTestCase {

    var userDefaults: UserDefaults!
    var filterViewModel: FilterViewModel!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        filterViewModel = FilterViewModel(userDefaults: userDefaults)
    }

    override func tearDown() {
        super.tearDown()
        userDefaults.removePersistentDomain(forName: #file)
        userDefaults = nil
        filterViewModel = nil
    }

    func test_selectedCategories_storesData() {
        let testCategories = ["Test1", "Test2", "Test3"]
        
        filterViewModel.selectedCategories = testCategories

        if let data = userDefaults.data(forKey: "selectedCategories"),
           let loadedCategories = try? JSONDecoder().decode([String].self, from: data) {
            XCTAssertEqual(loadedCategories, testCategories)
        } else {
            XCTFail("Failed to load selected categories from UserDefaults.")
        }
    }

    func test_filterStatus_storesData() {
        let testStatus = [Int16](1...3)

        filterViewModel.filterStatus = testStatus

        if let data = userDefaults.data(forKey: "filterStatus"),
           let loadedStatus = try? JSONDecoder().decode([Int16].self, from: data) {
            XCTAssertEqual(loadedStatus, testStatus)
        } else {
            XCTFail("Failed to load filter status from UserDefaults.")
        }
    }
    
    func test_selectedCategories_defaultValue() {
        let defaultCategories: [String] = []
        XCTAssertEqual(filterViewModel.selectedCategories, defaultCategories)
    }

    func test_filterStatus_defaultValue() {
        let defaultStatus: [Int16] = [0, 1, 2]
        XCTAssertEqual(filterViewModel.filterStatus, defaultStatus)
    }
}
