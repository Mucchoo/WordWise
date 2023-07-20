//
//  StudyViewUITests.swift
//  VocabAIUITests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest
@testable import VocabAI

final class StudyViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var helper: UITestHelper!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["FOR_TESTING", "SETUP_DATA_FOR_TESTING"]
        app.launch()
        
        helper = .init(app: app)
    }
    
    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func test_allButtons_shouldWork() throws {
        helper.tapButton("learnedFilterButton")
        helper.tapButton("learningFilterButton")
        helper.tapButton("newFilterButton")
        helper.tapButton("studyCategoryButton")
        helper.tapLeftTopArea()
        helper.tapButton("studyCardsButton")
    }
    
    func test_AllPickers_shouldExist() {
        helper.checkTextExistance("maximumCardsPicker")
        helper.checkTextExistance("failedTimesPicker")
    }
    
    func test_AllLabels_shouldExist() {
        helper.checkTextExistance("Learned")
        helper.checkTextExistance("Learning")
        helper.checkTextExistance("New")
        helper.checkTextExistance("Category")
        helper.checkTextExistance("Study")
    }
}
