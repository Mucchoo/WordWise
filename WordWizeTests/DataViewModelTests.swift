//
//  DataViewModelTests.swift
//  WordWizeTests
//
//  Created by Musa Yazuju on 7/16/23.
//

import XCTest
import CoreData
import Combine
@testable import WordWize

class DataViewModelTests: XCTestCase {
    var mockCardService: MockCardService!
    var dataViewModel: DataViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()

        mockCardService = MockCardService()
        let persistence = persistence(inMemory: true)
        dataViewModel = DataViewModel(cardService: mockCardService, persistence: persistence)
    }

    func test_maxStatusCount_calculatesMaxStatusCount() {
        for _ in 0..<5 {
            let cardCount = Int.random(in: 1...100)
            var statuses: [Int16: Int] = [:]
            
            for _ in 0..<cardCount {
                let status = Int16.random(in: 0...2)
                statuses[status, default: 0] += 1
                let card = dataViewModel.makeTestCard()
                card.status = status
                dataViewModel.cards.append(card)
            }
            
            dataViewModel.persistence.saveContext()
            let maxStatusCount = statuses.values.max() ?? 0
            XCTAssertEqual(dataViewModel.maxStatusCount, maxStatusCount)
            dataViewModel.cards.forEach { dataViewModel.deleteCard($0) }
            dataViewModel.cards.removeAll()
        }
    }
    
    func test_loadData_loadsCorrectData() {
        let cardCount = Int.random(in: 2...10)
        let categoryCount = Int.random(in: 1...5)

        var createdCards = Set<String>()
        var createdCategories = Set<String>()

        for _ in 0..<cardCount {
            let card = dataViewModel.makeTestCard()
            createdCards.insert(card.unwrappedText)
        }

        for i in 0..<categoryCount {
            let category = CardCategory(context: dataViewModel.viewContext)
            category.name = "category\(i)"
            createdCategories.insert(category.name!)
        }

        dataViewModel.persistence.saveContext()
        dataViewModel.loadData()
        
        let expectation = XCTestExpectation(description: "Data is loaded")

        DispatchQueue.main.async { [self] in
            let loadedCards = Set(dataViewModel.cards.map({ $0.unwrappedText }))
            let loadedCategories = Set(dataViewModel.categories.map({ $0.name! }))

            if createdCards == loadedCards && createdCategories == loadedCategories {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_updateCard_updatesCardData() {
        let card = dataViewModel.makeTestCard(text: "Test Card")
        card.status = 0
        card.failedTimes = 0
        
        try! dataViewModel.viewContext.save()
        let loadDataExpectation = expectation(description: "Data Loaded")
        
        dataViewModel.$cards
            .sink { cards in
                if !cards.isEmpty {
                    loadDataExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        dataViewModel.loadData()

        wait(for: [loadDataExpectation], timeout: 1)
        
        XCTAssertEqual(dataViewModel.cards.first?.text, "Test Card")
        XCTAssertEqual(dataViewModel.cards.first?.status, 0)

        let updateExpectation = expectation(description: "Card Updated")
        
        dataViewModel.updateCard(id: card.id!, text: "Updated Test Card", category: "Updated Category", status: 1, failedTimesIndex: 1)
        
        dataViewModel.$cards
            .sink { cards in
                if let updatedCard = cards.first,
                   updatedCard.text == "Updated Test Card" &&
                   updatedCard.status == 1 {
                    updateExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [updateExpectation], timeout: 1)
        
        XCTAssertEqual(dataViewModel.cards.first?.text, "Updated Test Card")
        XCTAssertEqual(dataViewModel.cards.first?.status, 1)
    }

    func test_deleteCard_deletesCardFromData() {
        let card = dataViewModel.makeTestCard()
        try! dataViewModel.viewContext.save()
        let loadDataExpectation = waitForCardsChange(to: { !$0.isEmpty }, description: "Data Loaded")
            
        dataViewModel.loadData()
        wait(for: [loadDataExpectation], timeout: 1)
        XCTAssertEqual(dataViewModel.cards.count, 1)
        
        let deleteExpectation = waitForCardsChange(to: { $0.isEmpty }, description: "Card Deleted")
        dataViewModel.deleteCard(card)

        wait(for: [deleteExpectation], timeout: 1)
        XCTAssertEqual(dataViewModel.cards.count, 0)
    }

    func test_addCategory_addsNewCategoryToData() {
        XCTAssertEqual(dataViewModel.categories.count, 0)
        
        let expectation = waitForCategoryChange(to: { $0.count == 1 }, description: "Category added")
        dataViewModel.addCategory(name: "Test Category")
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(dataViewModel.categories.first?.name, "Test Category")
    }
    
    func test_renameCategory_renamesExistingCategory() {
        dataViewModel.addCategory(name: "Test Category")
        
        let addExpectation = waitForCategoryChange(to: { !$0.isEmpty && $0.first?.name == "Test Category" }, description: "Category added")
        wait(for: [addExpectation], timeout: 1)

        dataViewModel.renameCategory(before: "Test Category", after: "Updated Category")
        
        let renameExpectation = waitForCategoryChange(to: { $0.first?.name == "Updated Category" }, description: "Category renamed")
        wait(for: [renameExpectation], timeout: 1)
    }

    func test_deleteCategory_deletesCategoryFromData() {
        dataViewModel.addCategory(name: "Test Category")
        
        let addExpectation = waitForCategoryChange(to: { !$0.isEmpty }, description: "Category added")
        wait(for: [addExpectation], timeout: 1)
        
        dataViewModel.deleteCategory(name: "Test Category")
        
        let deleteExpectation = waitForCategoryChange(to: { $0.isEmpty }, description: "Category deleted")
        wait(for: [deleteExpectation], timeout: 1)
    }

    func test_addCardPublisher_AddsCardsViaPublisher() {
        let words = ["word1", "word2"]
        let category = "test category"

        let mockCardResponse = CardResponse(word: "test", phonetic: "test", phonetics: [], origin: nil, meanings: [])
        mockCardService.mockCardResponse = mockCardResponse
        mockCardService.mockImageUrls = ["url1", "url2"]

        let expectation = self.expectation(description: "Cards added")
        let publisher = dataViewModel.addCardPublisher(text: words.joined(separator: "\n"), category: category)
        
        let cancellable = publisher.sink(receiveCompletion: { _ in
        }, receiveValue: { failedWords in
            XCTAssertTrue(failedWords.isEmpty, "There should be no failed words")
        })

        let cardsCancellable = dataViewModel.$cards
            .sink { cards in
                let allWordsProcessed = words.allSatisfy { word in
                    cards.contains { $0.text == word }
                }
                if allWordsProcessed {
                    expectation.fulfill()
                }
            }

        cancellables.insert(cancellable)
        cancellables.insert(cardsCancellable)
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_fetchCards_fetchesCardsCorrectly() {
        let words = ["word1", "word2"]
        let category = "test category"
        
        let publisher = dataViewModel.fetchCards(words: words, category: category)
        let cancellable = publisher.sink(receiveCompletion: { _ in }, receiveValue: { card in
            XCTAssertEqual(card.text, words.first, "Fetched card text should be equal to the first word")
        })

        cancellables.insert(cancellable)
    }
}

extension DataViewModelTests {
    func waitForCardsChange(to condition: @escaping ([Card]) -> Bool, description: String) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        
        dataViewModel.$cards
            .sink { cards in
                if condition(cards) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        return expectation
    }
    
    func waitForCategoryChange(to condition: @escaping ([CardCategory]) -> Bool, description: String) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        
        dataViewModel.$categories
            .sink { categories in
                DispatchQueue.main.async {
                    if condition(categories) {
                        expectation.fulfill()
                    }
                }
            }
            .store(in: &cancellables)
        
        return expectation
    }
}
