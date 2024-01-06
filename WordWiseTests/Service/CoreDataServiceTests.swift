//
//  SwiftDataServiceTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import SwiftData
import Combine
@testable import WordWise

class SwiftDataServiceTests: XCTestCase {
    
    var context: ModelContext!
    var networkService: NetworkServiceProtocol!
    var sut: SwiftDataService!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        let modelContainer = try! ModelContainer(for: Card.self, CardCategory.self)
        context = modelContainer.mainContext
        networkService = MockNetworkService()
        sut = .init(networkService: networkService, context: context)
        cancellables = []
    }
    
    override func tearDown() {
        context = nil
        networkService = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testRetryFetchingImages_CallsNetworkService() {
        let card = Card()
        card.retryFetchImages = true
        sut.retryFetchingImagesIfNeeded()
    }
    
    func testAddDefaultCategoryIfNeeded() {
        XCTAssertTrue(sut.categories.isEmpty)
        sut.addDefaultCategoryIfNeeded()
        XCTAssertEqual(sut.categories.count, 1)
    }
    
    func testAddDefaultCategoryIfNeeded_WithCompletion() {
        XCTAssertTrue(sut.categories.isEmpty)
        sut.addDefaultCategoryIfNeeded()
        XCTAssertTrue(self.sut.categories.first!.name == "Category 1")
    }

    func testSaveAndReload() {
        XCTAssertTrue(sut.cards.isEmpty)
        
        _ = Card()
        let expectation = self.expectation(description: "Wait for saveAndReload")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
        
        XCTAssertFalse(sut.cards.isEmpty)
    }

    func testDeleteDuplicatedCategory() {
        XCTAssertTrue(sut.categories.isEmpty)

        let category1 = CardCategory()
        category1.name = "Duplicate"
        let category2 = CardCategory()
        category2.name = "Duplicate"
        
        XCTAssertEqual(sut.categories.count, 2)
        let expectation = self.expectation(description: "Wait for loadData")
        
        DispatchQueue.main.async() {
            XCTAssertEqual(self.sut.categories.count, 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}
