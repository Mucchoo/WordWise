//
//  CardListViewUITests.swift
//  VocabAIUITests
//
//  Created by Musa Yazuju on 7/21/23.
//

import XCTest

final class CardListViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var helper: UITestHelper!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["FOR_TESTING", "SETUP_DATA_FOR_TESTING"]
        app.launch()
        
        helper = .init(app: app)
        helper.tapButton("cardListViewTabButton")
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func test_statusButtons_shouldBeTappable() throws {
        helper.tapButton("learnedFilterButton")
        helper.tapButton("learningFilterButton")
        helper.tapButton("newFilterButton")
    }
    
    func test_categoryButton_shouldShowCategoryList() {
        helper.tapButton("cardListCategoryButton")
        helper.checkTextExistance("Category 1")
        helper.checkTextExistance("Category")
        helper.checkButtonExistance("Rename")
    }
    
    func test_failedTimesPicker_shouldRespond() {
        helper.tapButton("cardListFailedTimesPicker")
        helper.checkTextExistance("0 or more times")
        helper.checkTextExistance("Failed Times")
    }
    
    func test_testCardList_shouldBeVisible() {
        helper.checkTextExistance("test card 1")
    }
}
