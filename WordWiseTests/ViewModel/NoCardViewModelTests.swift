//
//  NoCardViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWise

class NoCardViewModelTests: XCTestCase {

    var vm: NoCardViewModel!
    
    override func setUp() {
        super.setUp()
        vm = NoCardViewModel()
    }

    override func tearDown() {
        vm = nil
        super.tearDown()
    }

    func testAnimationStateInitiallyFalse() {
        XCTAssertFalse(vm.animate, "Initial state of animate should be false")
    }
    
    func testAnimationStateToggles() {
        let expectation = XCTestExpectation(description: "Wait for timer")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            XCTAssertTrue(self.vm.animate, "Animate should be true after 20 seconds")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 21)
    }
    
    func testTimerCancelOnDeinit() {
        vm = nil
        let expectation = XCTestExpectation(description: "Wait for timer after deinit")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 21)
    }
}
