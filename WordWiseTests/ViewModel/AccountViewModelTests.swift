//
//  AccountViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWise

class AccountViewModelTests: XCTestCase {

    var vm: AccountViewModel!

    @MainActor override func setUp() {
        super.setUp()
        vm = AccountViewModel(container: .mock(withMockCards: false))
    }

    override func tearDown() {
        vm.container.modelContainer.deleteAllData()
        vm = nil
        super.tearDown()
    }

    func testNativeLanguageInitialValue() {
        XCTAssertEqual(vm.nativeLanguage, "JA", "Initial native language should be 'JA'")
    }

    func testShowShareSheet() {
        vm.showShareSheet()
        XCTAssertTrue(vm.isShowingShareSheet, "Should show share sheet")
    }
    
    func testShowMail() {
        vm.showMail()
        XCTAssertTrue(vm.isShowingMail, "Should show mail")
    }
    
    func testShowResetAlert() {
        vm.showResetAlert()
        XCTAssertTrue(vm.showingResetAlert, "Should show reset alert")
    }
}
