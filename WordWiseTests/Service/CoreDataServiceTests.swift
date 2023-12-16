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
    var networkService: NetworkService!
    var appState: AppState!
    var sut: SwiftDataService!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor
    override func setUp() {
        super.setUp()
        
        let modelContainer = try! ModelContainer(for: Card.self, CardCategory.self)
        context = modelContainer.mainContext
        networkService = .init(session: .mock, context: context)
        appState = .init()
        sut = .init(networkService: networkService, appState: appState, context: context)
        cancellables = []
    }
    
    override func tearDown() {
        context = nil
        networkService = nil
        appState = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testRetryFetchingImages_CallsNetworkService() {
        let card = Card()
        card.retryFetchImages = true
        appState.cards = [card]
        sut.retryFetchingImagesIfNeeded()
    }
    
    func testAddDefaultCategoryIfNeeded() {
        XCTAssertTrue(appState.categories.isEmpty)
        sut.addDefaultCategoryIfNeeded()
        XCTAssertEqual(appState.categories.count, 1)
    }
    
    func testAddDefaultCategoryIfNeeded_WithCompletion() {
        XCTAssertTrue(appState.categories.isEmpty)
        sut.addDefaultCategoryIfNeeded()
        XCTAssertTrue(self.appState.categories.first!.name == "Category 1")
    }

    func testSaveAndReload() {
        XCTAssertTrue(appState.cards.isEmpty)
        
        _ = Card()
        let expectation = self.expectation(description: "Wait for saveAndReload")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
        
        XCTAssertFalse(appState.cards.isEmpty)
    }

    func testDeleteDuplicatedCategory() {
        XCTAssertTrue(appState.categories.isEmpty)

        let category1 = CardCategory()
        category1.name = "Duplicate"
        let category2 = CardCategory()
        category2.name = "Duplicate"
        appState.categories = [category1, category2]
        
        
        XCTAssertEqual(appState.categories.count, 2)
        let expectation = self.expectation(description: "Wait for loadData")
        
        DispatchQueue.main.async() {
            XCTAssertEqual(self.appState.categories.count, 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}
