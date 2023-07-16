//
//  StudyViewUITests.swift
//  VocabAIUITests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest

final class StudyViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    func testTapFilterButton() {
        let filterButton = app.buttons["filterButton"]
        XCTAssertTrue(filterButton.exists, "The filter button does not exist")
        filterButton.tap()
    }

    func testTapStudyCardsButton() {
        let studyCardsButton = app.buttons["studyCardsButton"]
        XCTAssertTrue(studyCardsButton.exists, "The study cards button does not exist")
        studyCardsButton.tap()
    }
}
