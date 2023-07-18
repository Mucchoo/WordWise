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

    func testTapStudyCardsButton() {
        waitForStudyView()
        let studyCardsButton = app.buttons["studyCardsButton"]
        XCTAssertTrue(studyCardsButton.exists, "The study cards button does not exist")
        studyCardsButton.tap()
    }
}

extension StudyViewUITests {
    func waitForStudyView() {
        let studyStaticText = app/*@START_MENU_TOKEN@*/.navigationBars["Study"]/*[[".otherElements[\"StudyView\"].navigationBars[\"Study\"]",".navigationBars[\"Study\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        wait(forElement: studyStaticText, timeout: 3)
    }
    
    func wait(forElement element: XCUIElement, timeout: TimeInterval) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
