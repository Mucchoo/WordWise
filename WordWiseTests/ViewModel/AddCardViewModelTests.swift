//
//  AddCardViewModelTests.swift
//  WordWiseTests
//
//  Created by Musa Yazuju on 9/6/23.
//

import XCTest
import Combine
@testable import WordWise

class AddCardViewModelTests: XCTestCase {
    
    var vm: AddCardViewModel!
    var cancellables: Set<AnyCancellable>!
    
    @MainActor override func setUp() {
        super.setUp()
        vm = .init(container: .mock())
        cancellables = []
    }
    
    override func tearDown() {
        vm = nil
        cancellables = nil
        MockURLProtocol.shouldFailUrls = []
        super.tearDown()
    }
    
    func testInitialValues() {
        XCTAssertEqual(vm.cardText, "")
        XCTAssertEqual(vm.selectedCategory, "")
        XCTAssertFalse(vm.generatingCards)
        XCTAssertTrue(vm.showPlaceholder)
        XCTAssertTrue(vm.fetchFailedWords.isEmpty)
        XCTAssertEqual(vm.requestedWordCount, 1)
        XCTAssertEqual(vm.fetchedWordCount, 0)
        XCTAssertEqual(vm.addedCardCount, 0)
        XCTAssertEqual(vm.textFieldInput, "")
        XCTAssertFalse(vm.showingAlert)
        XCTAssertNil(vm.currentAlert)
        XCTAssertEqual(vm.displayText, vm.placeHolder)
    }
    
    @MainActor func testGenerateCards() {
        let expectation = XCTestExpectation(description: "Generate cards")
        
        vm.cardText = "apple\norange"
        
        vm.$currentAlert.sink { alertType in
            if let alertType {
                XCTAssertEqual(alertType, .fetchSucceeded)
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        vm.generateCards()
        
        wait(for: [expectation], timeout: 1)
    }
    
    @MainActor func testFetchSucceeded() {
        let expectation = XCTestExpectation(description: "Fetch Succeeded")
        
        vm.$currentAlert.sink { alertType in
            if let alertType = alertType {
                XCTAssertEqual(alertType, .fetchSucceeded)
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        vm.generateCards()
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDisplayText() {
        vm.cardText = "apple"
        vm.showPlaceholder = false
        XCTAssertEqual(vm.displayText, "apple")
        
        vm.showPlaceholder = true
        XCTAssertEqual(vm.displayText, vm.placeHolder)
    }
    
    func testAlertTitleAndMessage() {
        vm.currentAlert = .addCategory
        XCTAssertEqual(vm.alertTitle, "Add Category")
        XCTAssertEqual(vm.alertMessage, "Please enter the new category name.")
        
        vm.currentAlert = .fetchFailed
        XCTAssertEqual(vm.alertTitle, "Failed to add cards")
        XCTAssertTrue(vm.alertMessage.contains("Failed to find these wards on the dictionary"))
        
        vm.currentAlert = .fetchSucceeded
        XCTAssertEqual(vm.alertTitle, "Added Cards")
        XCTAssertTrue(vm.alertMessage.contains("Added"))
    }
    
    func testShouldDisableAddCardButton() {
        vm.cardText = "   "
        XCTAssertTrue(vm.shouldDisableAddCardButton())
        
        vm.cardText = "apple"
        XCTAssertFalse(vm.shouldDisableAddCardButton())
    }
    
    func testUpdateTextEditor() {
        vm.updateTextEditor(text: "Apple", isFocused: false)
        XCTAssertEqual(vm.cardText, "apple")
    }
    
    func testTogglePlaceHolder() {
        vm.togglePlaceHolder(true)
        XCTAssertFalse(vm.showPlaceholder)
        
        vm.togglePlaceHolder(false)
        XCTAssertTrue(vm.showPlaceholder)
    }
    
    func testSetDefaultCategory() {
        vm.setDefaultCategory()
        XCTAssertEqual(vm.selectedCategory, MockHelper.shared.mockCategory)
    }
    
    func testAddDuplicateCategory() {
        vm.textFieldInput = MockHelper.shared.mockCategory
        vm.addCategory()
        let count = categories.filter { $0.name == MockHelper.shared.mockCategory }.count
        XCTAssertEqual(count, 1)
    }
    
    func testAddCategory() {
        let expectation = XCTestExpectation(description: "Category should be added")
        
        vm.textFieldInput = "Fruits"
        vm.addCategory()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(self.categories.contains { $0.name == "Fruits" })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    @MainActor func testRequestedAndFetchedWordCount() {
        let expectation = XCTestExpectation(description: "Fetch Completed")
        
        vm.cardText = "apple\norange"
        
        vm.$fetchedWordCount.sink { fetchedWordCount in
            if fetchedWordCount == 2 {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        vm.generateCards()
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(vm.requestedWordCount, 2)
        XCTAssertEqual(vm.fetchedWordCount, 2)
    }
    
    @MainActor func testGenerateCardsFail() {
        let expectation = XCTestExpectation(description: "generating cards")

        vm.cardText = "test"
        MockURLProtocol.shouldFailUrls = [APIURL.freeDictionary, APIURL.merriamWebster]
        vm.generateCards()
        
        vm.$showingAlert.sink { value in
            if value {
                XCTAssertEqual(self.vm.currentAlert, .fetchFailed)
                XCTAssertEqual(self.vm.fetchFailedWords, ["test"])
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateTextEditorShowPlaceholder() {
        vm.updateTextEditor(text: "", isFocused: false)
        XCTAssertTrue(vm.showPlaceholder)
    }
    
    func testTogglePlaceHolderShouldBeTrue() {
        vm.cardText = vm.placeHolder
        vm.togglePlaceHolder(false)
        XCTAssertTrue(vm.showPlaceholder)
    }
}
