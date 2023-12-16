//
//  ContentViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazuju on 9/5/23.
//

import XCTest
@testable import WordWise

class ContentViewModelTests: XCTestCase {
    var viewModel: ContentViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ContentViewModel(container: .mock())
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialTabIsStudy() {
        XCTAssertEqual(viewModel.selectedTab, TabType.study.rawValue, "Initial tab is not set to study")
    }
  
    func testSelectedTabChange() {
        viewModel.selectedTab = TabType.addCard.rawValue
        XCTAssertEqual(viewModel.selectedTab, TabType.addCard.rawValue, "selectedTab did not change to addCard")
    }
  
    func testTabPointsUpdate() {
        let testPoints: [CGFloat] = [10, 20, 30, 40]
        viewModel.tabPoints = testPoints
        XCTAssertEqual(viewModel.tabPoints, testPoints, "tabPoints did not update correctly")
    }
}
