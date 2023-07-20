//
//  StudyViewUITests.swift
//  VocabAIUITests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest
import CoreData
@testable import VocabAI

final class StudyViewUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["FOR_TESTING", "SETUP_DATA_FOR_TESTING"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func test_allButtons_shouldWork() throws {
        tapButton("learnedFilterButton")
        tapButton("learningFilterButton")
        tapButton("newFilterButton")
        tapButton("studyCategoryButton")
        tapLeftTopArea()
        tapButton("studyCardsButton")
    }
    
    func test_AllPickers_shouldExist() {
        checkTextExistance("maximumCardsPicker")
        checkTextExistance("failedTimesPicker")
    }
    
    func test_AllLabels_shouldExist() {
        checkTextExistance("Learned")
        checkTextExistance("Learning")
        checkTextExistance("New")
        checkTextExistance("Category")
        checkTextExistance("Study")
    }
}

extension StudyViewUITests {
    func tapLeftTopArea() {
        let leftTopArea = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
        leftTopArea.tap()
    }
    
    func checkExistance(_ id: String) {
        let view = app.otherElements[id]
        let doesExist = view.waitForExistence(timeout: 3)
        XCTAssertTrue(doesExist, "\(id) does not exist.")
    }
    
    func checkTextExistance(_ text: String) {
        let view = app.staticTexts[text]
        let doesExist = view.waitForExistence(timeout: 3)
        XCTAssertTrue(doesExist, "\(text) does not exist.")
    }
    
    func tapButton(_ id: String) {
        let button = app.buttons[id]
        XCTAssertTrue(button.exists, "\(id) does not exist.")
        button.tap()
    }
    
    func wait(forElement element: XCUIElement, timeout: TimeInterval) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
// move to tabbar UITests
//    func test_tabBarIcon_shouldBefilledStyle() {
//
//    }
//
//    func test_tabBarIcon_shouldShowDotCorrectly() {
//
//    }
