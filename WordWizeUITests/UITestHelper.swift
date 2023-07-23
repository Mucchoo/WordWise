//
//  UITestHelper.swift
//  WordWizeUITests
//
//  Created by Musa Yazuju on 7/20/23.
//

import XCTest

struct UITestHelper {
    var app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

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
    
    @discardableResult func checkButtonExistance(_ id: String) -> XCUIElement {
        let button = app.buttons[id]
        let doesExist = button.waitForExistence(timeout: 3)
        XCTAssertTrue(doesExist, "\(id) does not exist.")
        return button
    }
    
    func tapButton(_ id: String) {
        let button = checkButtonExistance(id)
        button.tap()
    }
    
    func wait(forElement element: XCUIElement, timeout: TimeInterval, testCase: XCTestCase) {
        let existsPredicate = NSPredicate(format: "exists == true")
        testCase.expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        testCase.waitForExpectations(timeout: timeout, handler: nil)
    }
        
    func selectAlertButton(title: String, button: String) {
        app.alerts[title].scrollViews.otherElements.buttons[button].tap()
    }
    
    func getAlertButton(title: String, button: String) -> XCUIElement {
        return app.alerts[title].scrollViews.otherElements.buttons[button]
    }
}
