//
//  VocabAITests.swift
//  VocabAITests
//
//  Created by Musa Yazuju on 7/16/23.
//

import XCTest
@testable import VocabAI

final class VocabAITests: XCTestCase {

    var vocabAIApp: VocabAIApp!

    override func setUpWithError() throws {
        try super.setUpWithError()
        vocabAIApp = VocabAIApp()
    }

    override func tearDownWithError() throws {
        vocabAIApp = nil
        try super.tearDownWithError()
    }

    func testAppInitialization() throws {
        XCTAssertNotNil(vocabAIApp.cardService, "CardService should not be nil.")
        XCTAssertNotNil(vocabAIApp.dataViewModel, "DataViewModel should not be nil.")
    }

    func testDataViewModelSetup() throws {
        XCTAssertNotNil(vocabAIApp.dataViewModel.cardService, "CardService in DataViewModel should not be nil.")
        XCTAssertNotNil(vocabAIApp.dataViewModel.persistence, "Persistence in DataViewModel should not be nil.")
    }

    func testPerformanceExample() throws {
        self.measure {
            _ = VocabAIApp()
        }
    }
}
