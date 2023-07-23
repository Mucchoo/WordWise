//
//  WordWizeTests.swift
//  WordWizeTests
//
//  Created by Musa Yazuju on 7/16/23.
//

import XCTest
@testable import WordWize

final class WordWizeTests: XCTestCase {

    var WordWizeApp: WordWizeApp!

    override func setUpWithError() throws {
        try super.setUpWithError()
        WordWizeApp = WordWizeApp()
    }

    override func tearDownWithError() throws {
        WordWizeApp = nil
        try super.tearDownWithError()
    }

    func testAppInitialization() throws {
        XCTAssertNotNil(WordWizeApp.cardService, "CardService should not be nil.")
        XCTAssertNotNil(WordWizeApp.dataViewModel, "DataViewModel should not be nil.")
    }

    func testDataViewModelSetup() throws {
        XCTAssertNotNil(WordWizeApp.dataViewModel.cardService, "CardService in DataViewModel should not be nil.")
        XCTAssertNotNil(WordWizeApp.dataViewModel.persistence, "Persistence in DataViewModel should not be nil.")
    }

    func testPerformanceExample() throws {
        self.measure {
            _ = WordWizeApp()
        }
    }
}
