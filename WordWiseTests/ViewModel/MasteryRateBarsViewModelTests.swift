//
//  MasteryRateBarsViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWise
import SwiftData

class MasteryRateBarsViewModelTests: XCTestCase {
    
    var vm: MasteryRateBarsViewModel!
    let helper = MockHelper.shared
    
    @MainActor override func setUp() {
        super.setUp()
        
        vm = MasteryRateBarsViewModel(container: .mock(withMockCards: false), categoryName: "")
    }
    
    override func tearDown() {
        vm = nil
        super.tearDown()
    }
    
    func testInitialValues() {
        XCTAssertFalse(vm.isLoaded, "Initial isLoaded should be false")
        XCTAssertEqual(vm.countTexts[.zero], "", "Initial countText for .zero should be an empty string")
        XCTAssertEqual(vm.barWidths[.zero], 45, "Initial barWidth for .zero should be 45")
    }
    
    func testMaxCount() {
        let cards = [
            helper.mockCard(rate: .zero),
            helper.mockCard(rate: .twentyFive),
            helper.mockCard(rate: .twentyFive),
            helper.mockCard(rate: .fifty),
            helper.mockCard(rate: .seventyFive),
            helper.mockCard(rate: .seventyFive),
            helper.mockCard(rate: .seventyFive)
        ]
        
        XCTAssertEqual(vm.maxCount, 3, "MaxCount should be 3")
    }
    
    func testMaxCountWithNoCards() {
        XCTAssertEqual(vm.maxCount, 1)
    }
    
    func testCountForRate() {
        let cards = [
            helper.mockCard(rate: .zero),
            helper.mockCard(rate: .twentyFive),
            helper.mockCard(rate: .twentyFive),
            helper.mockCard(rate: .fifty)
        ]
        
        XCTAssertEqual(self.vm.getCount(.twentyFive), "2", "Count for rate twentyFive should be 2")
    }

    
    func testSetWidthAndCountText() {
        let cards = [
            helper.mockCard(rate: .zero),
            helper.mockCard(rate: .twentyFive),
            helper.mockCard(rate: .twentyFive),
            helper.mockCard(rate: .fifty),
            helper.mockCard(rate: .seventyFive),
            helper.mockCard(rate: .seventyFive),
            helper.mockCard(rate: .seventyFive)
        ]
        
        vm.setWidthAndCountText(geometryWidth: 100)
        
        XCTAssertEqual(vm.barWidths[.zero], 90 + (100 - 90) * 1 / 3, "Bar width for .zero should be updated correctly")
        XCTAssertEqual(vm.countTexts[.zero], "1", "Count text for .zero should be '1'")
    }
}
