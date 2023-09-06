//
//  NoCardViewTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWize

class NoCardViewModelTests: XCTestCase {

    var viewModel: NoCardViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = NoCardViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testAnimationStateInitiallyFalse() {
        XCTAssertFalse(viewModel.animate, "Initial state of animate should be false")
    }
    
    func testAnimationStateToggles() {
        let expectation = XCTestExpectation(description: "Wait for timer")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            XCTAssertTrue(self.viewModel.animate, "Animate should be true after 20 seconds")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 21)
    }
    
    func testTimerCancelOnDeinit() {
        viewModel = nil
        let expectation = XCTestExpectation(description: "Wait for timer after deinit")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 21)
    }
}
