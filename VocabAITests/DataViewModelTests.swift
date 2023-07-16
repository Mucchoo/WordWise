//
//  DataViewModelTests.swift
//  VocabAITests
//
//  Created by Musa Yazuju on 7/16/23.
//

import XCTest
import CoreData
import Combine
@testable import VocabAI

class DataViewModelTests: XCTestCase {
    var mockCardService: MockCardService!
    var mockPersistence: MockPersistence!
    var dataViewModel: DataViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()

        mockCardService = MockCardService()
        mockPersistence = MockPersistence()

        dataViewModel = DataViewModel(cardService: mockCardService, persistence: mockPersistence)
    }

    func testMaxStatusCount() {
        let card1 = Card(context: mockPersistence.viewContext)
        card1.status = 0
        let card2 = Card(context: mockPersistence.viewContext)
        card2.status = 1
        let card3 = Card(context: mockPersistence.viewContext)
        card3.status = 1
        let card4 = Card(context: mockPersistence.viewContext)
        card4.status = 2
        let card5 = Card(context: mockPersistence.viewContext)
        card5.status = 2
        let card6 = Card(context: mockPersistence.viewContext)
        card6.status = 2

        dataViewModel.cards = [card1, card2, card3, card4, card5, card6]
        XCTAssertEqual(dataViewModel.maxStatusCount, 3)
    }
    
    func testLoadData() {
        let expectation = XCTestExpectation(description: "Data is loaded")

        let card1 = Card(context: mockPersistence.viewContext)
        card1.text = "card1"
        card1.id = UUID()
        let card2 = Card(context: mockPersistence.viewContext)
        card2.text = "card2"
        card2.id = UUID()

        let category1 = CardCategory(context: mockPersistence.viewContext)
        category1.name = "category1"

        mockPersistence.saveContext()
        dataViewModel.loadData()

        DispatchQueue.main.async { [self] in
            if dataViewModel.cards.count == 2 &&
               dataViewModel.cards.map({ $0.unwrappedText }).sorted() == ["card1", "card2"] &&
               dataViewModel.categories.count == 1 &&
               dataViewModel.categories.first?.name == "category1" {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateCard() {
        let card = Card(context: mockPersistence.viewContext)
        card.id = UUID()
        card.text = "Test Card"
        card.status = 0
        card.failedTimes = 0
        
        try! mockPersistence.viewContext.save()
        
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

    func testDeleteCard() {
        let card = Card(context: mockPersistence.viewContext)
        card.text = "Test Card"
        card.id = UUID()
        try! mockPersistence.viewContext.save()
        
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
        
        XCTAssertEqual(dataViewModel.cards.count, 1)
        
        let deleteExpectation = expectation(description: "Card Deleted")
        
        dataViewModel.deleteCard(card)
        
        dataViewModel.$cards
            .sink { cards in
                if cards.isEmpty {
                    deleteExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        wait(for: [deleteExpectation], timeout: 1)
        
        XCTAssertEqual(dataViewModel.cards.count, 0)
    }

    func testAddCategory() {
        XCTAssertEqual(dataViewModel.categories.count, 0)

        let expectation = self.expectation(description: "Category added")

        dataViewModel.addCategory(name: "Test Category")

        DispatchQueue.main.async {
            if self.dataViewModel.categories.count == 1 {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(dataViewModel.categories.first?.name, "Test Category")
    }

    func testRenameCategory() {
        dataViewModel.addCategory(name: "Test Category")

        let expectation = self.expectation(description: "Category renamed")

        DispatchQueue.main.async {
            if self.dataViewModel.categories.first?.name == "Test Category" {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)

        dataViewModel.renameCategory(before: "Test Category", after: "Updated Category")

        let renameExpectation = self.expectation(description: "Category rename check")

        DispatchQueue.main.async {
            if self.dataViewModel.categories.first?.name == "Updated Category" {
                renameExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testDeleteCategory() {
        dataViewModel.addCategory(name: "Test Category")

        let expectation = self.expectation(description: "Category added")

        DispatchQueue.main.async {
            if self.dataViewModel.categories.count == 1 {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)

        dataViewModel.deleteCategory(name: "Test Category")

        let deleteExpectation = self.expectation(description: "Category delete check")

        DispatchQueue.main.async {
            if self.dataViewModel.categories.isEmpty {
                deleteExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 1)
    }

    func testAddCardPublisher() {
        let cardService = MockCardService()
        let persistence = MockPersistence()

        let dataViewModel = DataViewModel(cardService: cardService, persistence: persistence)
        let words = ["word1", "word2"]
        let category = "test category"

        // Set up mock responses for each word
        let mockCardResponse = CardResponse(word: "test", phonetic: "test", phonetics: [], origin: nil, meanings: [])
        cardService.mockCardResponse = mockCardResponse
        cardService.mockImageUrls = ["url1", "url2"]

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

    func testFetchCards() {
        let cardService = MockCardService()
        let persistence = MockPersistence()

        let dataViewModel = DataViewModel(cardService: cardService, persistence: persistence)
        let words = ["word1", "word2"]
        let category = "test category"
        
        let publisher = dataViewModel.fetchCards(words: words, category: category)
        let cancellable = publisher.sink(receiveCompletion: { _ in }, receiveValue: { card in
            XCTAssertEqual(card.text, words.first, "Fetched card text should be equal to the first word")
        })

        cancellables.insert(cancellable)
    }

    func testFetch() {
        let cardService = MockCardService()

        let publisher = cardService.fetch(word: "test")
        let cancellable = publisher.sink(receiveCompletion: { _ in }, receiveValue: { cardResponse in
            XCTAssertEqual(cardResponse.word, "test", "Fetched word should be equal to 'test'")
        })

        cancellables.insert(cancellable)
    }

    func testFetchImages() {
        let cardService = MockCardService()

        let publisher = cardService.fetchImages(word: "test")
        let cancellable = publisher.sink(receiveCompletion: { _ in }, receiveValue: { imageUrls in
            XCTAssertFalse(imageUrls.isEmpty, "Fetched image URLs should not be empty")
        })

        cancellables.insert(cancellable)
    }
}

class MockCardService: CardService {
    var mockCardResponse: CardResponse?
    var fetchError: Error?

    var mockImageUrls: [String]?
    var fetchImagesError: Error?
    
    func fetch(word: String) -> AnyPublisher<CardResponse, Error> {
        if let error = fetchError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockCardResponse {
            return Just(response).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
    
    func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        if let error = fetchImagesError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let urls = mockImageUrls {
            return Just(urls).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
}

class MockPersistence: Persistence {
    var container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    init() {
        container = NSPersistentContainer(name: "Card")
        container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error.localizedDescription), \(error as NSError).userInfo")
            }
        }
    }
}
