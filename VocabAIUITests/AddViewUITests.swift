//
//  AddViewUITests.swift
//  VocabAIUITests
//
//  Created by Musa Yazuju on 7/21/23.
//

import XCTest
@testable import VocabAI

final class AddViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var helper: UITestHelper!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["FOR_TESTING", "SETUP_DATA_FOR_TESTING"]
        app.launch()
        
        helper = .init(app: app)
        helper.tapButton("addViewTabButton")
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func test_addCategoryButton_shouldShowAlert() throws {
        helper.tapButton("addCategoryButton")
        helper.selectAlertCancelButton()
    }
    
    func test_categoryPicker_shouldShowCategoryOptions() {
        let picker = app.buttons["addViewCategoryPicker"]
        XCTAssertTrue(picker.exists, "Picker does not exist") // failed
        picker.tap()
        helper.checkTextExistance("Category 1")
    }
    
    func test_textEditor_shouldRespondToKeyboard() {
        let textEditor = app.textViews["addViewTextEditor"]
        XCTAssertTrue(textEditor.exists, "Text editor does not exist")
        textEditor.tap()
        textEditor.typeText("test")
    }
    
    func test_addCardsButton_shouldBeTappable() {
        helper.tapButton("addCardsButton")
    }
}
