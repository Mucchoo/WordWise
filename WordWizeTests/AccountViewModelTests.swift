//
//  AccountViewModelTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/7/23.
//

import XCTest
@testable import WordWize

class AccountViewModelTests: XCTestCase {

    var vm: AccountViewModel!

    override func setUp() {
        super.setUp()
        vm = AccountViewModel(container: .mock(withMockCards: false))
    }

    override func tearDown() {
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
    
    func testResetLearningData() {
        let card = Card(context: vm.container.persistence.viewContext)
        card.masteryRate = 1
        card.lastHardDate = Date()
        card.nextLearningDate = Date()
        vm.container.appState.cards = [card]
        vm.resetLearningData()

        let updatedCard = vm.container.appState.cards.first!
        XCTAssertEqual(updatedCard.masteryRate, 0, "Mastery rate should be reset to 0")
        XCTAssertNil(updatedCard.lastHardDate, "Last hard date should be nil")
        XCTAssertNil(updatedCard.nextLearningDate, "Next learning date should be nil")
    }
}
