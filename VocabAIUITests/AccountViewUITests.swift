//
//  AccountViewUITests.swift
//  VocabAIUITests
//
//  Created by Musa Yazuju on 7/21/23.
//

import XCTest

final class AccountViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var helper: UITestHelper!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["FOR_TESTING", "SETUP_DATA_FOR_TESTING"]
        app.launch()
        
        helper = .init(app: app)
        helper.tapButton("accountViewTabButton")
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func test_allTexts_shouldBeVisible() {
        helper.checkTextExistance("Account")
        helper.checkTextExistance("emailAddressText")
    }
    
    func test_chartBars_shouldBeVisible() {
        helper.checkTextExistance("chartBar0")
        helper.checkTextExistance("chartBar1")
        helper.checkTextExistance("chartBar2")
    }
    
    func test_resetLearningDataButton_shouldShowAlert() {
        let alertTitle = "Are you sure to reset all the learning data?"

        helper.tapButton("resetLearningDataButton")
        helper.selectAlertButton(title: alertTitle, button: "Cancel")
        helper.tapButton("resetLearningDataButton")
        helper.selectAlertButton(title: alertTitle, button: "Reset")
    }
    
    func test_shareButton_shouldBeEnabled() {
        let button = helper.checkButtonExistance("shareButton")
        XCTAssertTrue(button.isEnabled)
    }
    
    func test_feedbackButton_shouldBeEnabled() {
        let button = helper.checkButtonExistance("feedbackButton")
        XCTAssertTrue(button.isEnabled)
    }
}
