//
//  AddCardViewUITests.swift
//  WordWizeUITests
//
//  Created by Musa Yazuju on 7/21/23.
//

import XCTest
@testable import WordWize

final class AddCardViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var helper: UITestHelper!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["FOR_TESTING", "SETUP_DATA_FOR_TESTING"]
        app.launch()
        
        helper = .init(app: app)
        helper.tapButton("addCardViewTabButton")
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func test_addCategoryButton_shouldShowAlert() {
        let alertTitle = "Add Category"
        let addButton = helper.getAlertButton(title: alertTitle, button: "Add")

        helper.tapButton("addCategoryButton")
        XCTAssertFalse(addButton.isEnabled)
        helper.selectAlertButton(title:alertTitle, button: "Cancel")
    }
    
    func test_categoryPicker_shouldShowCategoryOptions() {
        let picker = app.buttons["addCardViewCategoryPicker"]
        XCTAssertTrue(picker.exists, "Picker does not exist")
        picker.tap()
        helper.checkTextExistance("Category 1")
    }
    
    func test_textEditor_shouldRespondToKeyboard() {
        let textEditor = app.textViews["addCardViewTextEditor"]
        XCTAssertTrue(textEditor.exists, "Text editor does not exist")
        textEditor.tap()
        textEditor.typeText("test")
    }
    
    func test_addCardsButton_shouldBeTappable() {
        helper.tapButton("addCardsButton")
    }
    
    func test_navigationBarTitle_shouldBeVisible() {
        helper.checkTextExistance("Add Cards")
    }
}
