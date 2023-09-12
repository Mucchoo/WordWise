//
//  MasteryRateBarsViewModelTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWize
import CoreData

class MasteryRateBarsViewModelTests: XCTestCase {
    
    var vm: MasteryRateBarsViewModel!
    var context: NSManagedObjectContext!
    let helper = MockHelper.shared
    
    override func setUp() {
        super.setUp()
        
        vm = MasteryRateBarsViewModel(container: .mock(withMockCards: false), categoryName: "")
        context = vm.container.persistence.viewContext
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
            helper.mockCard(rate: .zero, context: context),
            helper.mockCard(rate: .twentyFive, context: context),
            helper.mockCard(rate: .twentyFive, context: context),
            helper.mockCard(rate: .fifty, context: context),
            helper.mockCard(rate: .seventyFive, context: context),
            helper.mockCard(rate: .seventyFive, context: context),
            helper.mockCard(rate: .seventyFive, context: context)
        ]
        
        vm.container.appState.cards = cards
        vm.container.coreDataService.saveAndReload()
        
        XCTAssertEqual(vm.maxCount, 3, "MaxCount should be 3")
    }
    
    func testMaxCountWithNoCards() {
        vm.container.appState.cards = []
        XCTAssertEqual(vm.maxCount, 1)
    }
    
    func testCountForRate() {
        let cards = [
            helper.mockCard(rate: .zero, context: context),
            helper.mockCard(rate: .twentyFive, context: context),
            helper.mockCard(rate: .twentyFive, context: context),
            helper.mockCard(rate: .fifty, context: context)
        ]
        vm.container.appState.cards = cards
        
        XCTAssertEqual(self.vm.getCount(.twentyFive), "2", "Count for rate twentyFive should be 2")
    }

    
    func testSetWidthAndCountText() {
        let cards = [
            helper.mockCard(rate: .zero, context: context),
            helper.mockCard(rate: .twentyFive, context: context),
            helper.mockCard(rate: .twentyFive, context: context),
            helper.mockCard(rate: .fifty, context: context),
            helper.mockCard(rate: .seventyFive, context: context),
            helper.mockCard(rate: .seventyFive, context: context),
            helper.mockCard(rate: .seventyFive, context: context)
        ]
        
        vm.container.appState.cards = cards
        vm.setWidthAndCountText(geometryWidth: 100)
        vm.container.coreDataService.saveAndReload()
        
        XCTAssertEqual(vm.barWidths[.zero], 90 + (100 - 90) * 1 / 3, "Bar width for .zero should be updated correctly")
        XCTAssertEqual(vm.countTexts[.zero], "1", "Count text for .zero should be '1'")
    }
}
