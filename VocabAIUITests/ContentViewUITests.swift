//
//  ContentViewUITests.swift
//  VocabAITests
//
//  Created by Musa Yazuju on 7/17/23.
//

import XCTest

class ContentViewUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication(bundleIdentifier: "yazujumusa.VocabAI")
        app.launch()
    }

    func testTabSelection() {
        app.buttons["book.closed"].tap()
        XCTAssert(app.otherElements["StudyView"].exists)
        
        app.buttons["plus.square"].tap()
        XCTAssert(app.otherElements["AddCardView"].exists)
        
        app.buttons["rectangle.stack"].tap()
        XCTAssert(app.otherElements["CardListView"].exists)
        
        app.buttons["person"].tap()
        XCTAssert(app.otherElements["AccountView"].exists)
    }
}
