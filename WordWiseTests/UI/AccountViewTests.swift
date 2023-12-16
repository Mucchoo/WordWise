//
//  AccountViewTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
import ViewInspector
import SwiftUI
@testable import WordWise

class AccountViewTests: XCTestCase {
    
    var sut: AccountView!
    var vm: AccountViewModel!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = AccountViewModel(container: .mock())
        sut = AccountView(vm: vm)
    }

    override func tearDown() {
        sut = nil
        vm = nil
        super.tearDown()
    }
    
    func testNavigationLink() throws {
        let navigationLink = try sut.inspect().navigationView().find(ViewType.NavigationLink.self)
        XCTAssertEqual(try navigationLink.labelView().text().string(), "What is Mastery Rate?")
    }
    
    func testNativeLanguagePicker() throws {
        XCTAssertNoThrow(try sut.inspect().find(ViewType.Picker.self))
    }
    
    func testFindButton() throws {
        XCTAssertNoThrow(try sut.inspect().find(viewWithAccessibilityIdentifier: "shareAppButton"))
        XCTAssertNoThrow(try sut.inspect().find(viewWithAccessibilityIdentifier: "feedbackButton"))
    }
    
    func testPickerOptions() throws {
        let picker = try sut.inspect().find(ViewType.Picker.self)
        try PickerOptions.language.forEach { language in
            try picker.select(value: language.name)
        }
    }
}
