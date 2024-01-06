//
//  PickerAlertTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

//import XCTest
//import SwiftUI
//import ViewInspector
//@testable import WordWise
//
//class PickerAlertTests: XCTestCase {
//    
//    var vm: CardListViewModel!
//    
//    @MainActor override func setUp() {
//        super.setUp()
//        vm = CardListViewModel(container: .mock(), category: MockHelper.shared.mockCategory)
//    }
//    
//    override func tearDown() {
//        vm = nil
//        super.tearDown()
//    }
//    
//    func testPickerAlertInitWithCategory() {
//        vm.pickerAlertType = .category
//        let sut = PickerAlert(vm: vm)
//        
//        XCTAssertEqual(sut.title, "Change Category")
//        XCTAssertEqual(sut.message, "Select new category for the 0 cards.")
//        XCTAssertEqual(sut.options, [MockHelper.shared.mockCategory])
//    }
//    
//    func testPickerAlertInitWithMasteryRate() {
//        vm.pickerAlertType = .masteryRate
//        let sut = PickerAlert(vm: vm)
//
//        let options: [String] = MasteryRate.allValues.map { $0.stringValue() + "%" }
//        XCTAssertEqual(sut.title, "Change Mastery Rate")
//        XCTAssertEqual(sut.message, "Select Mastery Rate for the 0 cards.")
//        XCTAssertEqual(sut.options, options)
//    }
//    
//    func testAlertConfigurationForCategory() throws {
//        vm.pickerAlertType = .category
//        let sut = PickerAlert(vm: vm)
//        
//        XCTAssertEqual(sut.title, "Change Category")
//        XCTAssertEqual(sut.message, "Select new category for the \(vm.selectedCards.count) cards.")
//        
//        let expectedOptions = categories
//        XCTAssertEqual(sut.options, expectedOptions)
//    }
//    
//    func testAlertConfigurationForMasteryRate() throws {
//        vm.pickerAlertType = .masteryRate
//        let sut = PickerAlert(vm: vm)
//
//        XCTAssertEqual(sut.title, "Change Mastery Rate")
//        XCTAssertEqual(sut.message, "Select Mastery Rate for the \(vm.selectedCards.count) cards.")
//        
//        let expectedOptions = MasteryRate.allValues.map { $0.stringValue() + "%" }
//        XCTAssertEqual(sut.options, expectedOptions)
//    }
//}
