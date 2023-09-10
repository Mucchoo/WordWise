//
//  PickerAlertTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import WordWize

class PickerAlertTests: XCTestCase {
    
    var vm: CardListViewModel!
    var sut: PickerAlert!
    
    override func setUp() {
        super.setUp()
        vm = CardListViewModel(container: .mock(), categoryName: MockHelper.shared.mockCategory)
    }
    
    override func tearDown() {
        vm = nil
        sut = nil
        super.tearDown()
    }
    
    func testPickerAlertInitWithCategory() {
        sut = PickerAlert(vm: vm, type: .category)
        
        XCTAssertEqual(sut.title, "Change Category")
        XCTAssertEqual(sut.message, "Select new category for the 0 cards.")
        XCTAssertEqual(sut.options, [MockHelper.shared.mockCategory])
    }
    
    func testPickerAlertInitWithMasteryRate() {
        sut = PickerAlert(vm: vm, type: .masteryRate)
        let options: [String] = MasteryRate.allValues.map { $0.stringValue() + "%" }
        
        XCTAssertEqual(sut.title, "Change Mastery Rate")
        XCTAssertEqual(sut.message, "Select Mastery Rate for the 0 cards.")
        XCTAssertEqual(sut.options, options)
    }
    
    func testAlertConfigurationForCategory() throws {
        sut = PickerAlert(vm: vm, type: .category)
        
        XCTAssertEqual(sut.title, "Change Category")
        XCTAssertEqual(sut.message, "Select new category for the \(vm.selectedCards.count) cards.")
        
        let expectedOptions = vm.container.appState.categories.map { $0.name ?? "" }
        XCTAssertEqual(sut.options, expectedOptions)
    }
    
    func testAlertConfigurationForMasteryRate() throws {
        sut = PickerAlert(vm: vm, type: .masteryRate)
        
        XCTAssertEqual(sut.title, "Change Mastery Rate")
        XCTAssertEqual(sut.message, "Select Mastery Rate for the \(vm.selectedCards.count) cards.")
        
        let expectedOptions = MasteryRate.allValues.map { $0.stringValue() + "%" }
        XCTAssertEqual(sut.options, expectedOptions)
    }
}
