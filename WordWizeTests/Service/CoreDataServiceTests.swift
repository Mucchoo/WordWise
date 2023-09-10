//
//  CoreDataServiceTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import CoreData
import Combine
@testable import WordWize

class CoreDataServiceTests: XCTestCase {
    
    var persistence: Persistence!
    var networkService: MockNetworkService!
    var appState: AppState!
    var sut: CoreDataService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        persistence = .init(isMock: true)
        networkService = .init()
        appState = .init()
        sut = .init(persistence: persistence, networkService: networkService, appState: appState)
        cancellables = []
    }
    
    override func tearDown() {
        persistence = nil
        networkService = nil
        appState = nil
        sut = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testRetryFetchingImages_CallsNetworkService() {
        let card = Card(context: persistence.viewContext)
        card.retryFetchImages = true
        appState.cards = [card]
        sut.retryFetchingImages()
    }
    
    func testAddDefaultCategoryIfNeeded() {
        XCTAssertTrue(appState.categories.isEmpty)
        sut.addDefaultCategoryIfNeeded()
        XCTAssertEqual(appState.categories.count, 1)
    }
    
    func testAddDefaultCategoryIfNeeded_WithCompletion() {
        XCTAssertTrue(appState.categories.isEmpty)
        sut.addDefaultCategoryIfNeeded {
            XCTAssertTrue(self.appState.categories.first!.name == "Category 1")
        }
    }

    func testSaveAndReload() {
        XCTAssertTrue(appState.cards.isEmpty)
        
        let card = Card(context: persistence.viewContext)
        sut.saveAndReload()
        
        let expectation = self.expectation(description: "Wait for saveAndReload")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 3, handler: nil)
        
        XCTAssertFalse(appState.cards.isEmpty)
    }

    func testDeleteDuplicatedCategory() {
        XCTAssertTrue(appState.categories.isEmpty)

        let category1 = CardCategory(context: persistence.viewContext)
        category1.name = "Duplicate"
        let category2 = CardCategory(context: persistence.viewContext)
        category2.name = "Duplicate"
        appState.categories = [category1, category2]
        
        
        XCTAssertEqual(appState.categories.count, 2)
        let expectation = self.expectation(description: "Wait for loadData")
        sut.loadData()
        
        DispatchQueue.main.async() {
            XCTAssertEqual(self.appState.categories.count, 1)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3)
    }
}
