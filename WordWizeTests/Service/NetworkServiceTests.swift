//
//  NetworkServiceTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import Combine
import CoreData
@testable import WordWize

class NetworkServiceTests: XCTestCase {
    var sut: NetworkService!
    var mockSession: URLSession!
    var cancellables: Set<AnyCancellable>!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        mockSession = .mock
        sut = NetworkService(session: .mock)
        cancellables = []
        context = Persistence(isMock: true).viewContext
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        cancellables = nil
        context = nil
        super.tearDown()
    }
    
    func testFetchDefinitionsAndImages_FreeAPI_Success() {
        let card = Card(context: context)
        card.text = "example"

        let publisher = sut.fetchDefinitionsAndImages(card: card, context: context)
        let expectation = XCTestExpectation(description: "Network call succeeds.")

        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Test: Finished without error.")
                case .failure(let error):
                    print("Test: Finished with error: \(error)")
                    XCTAssertNil(error)
                }
                expectation.fulfill()
            },
            receiveValue: { card in
                print("Test: Received card: \(card)")
                XCTAssertNotNil(card)
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
    }
    
    func testFetchDefinitionsAndImages_MerriamWebster_Success() {
        let card = Card(context: context)
        card.text = "example"
        
        MockURLProtocol.shouldFailUrl = APIURL.freeDictionary
        let publisher = sut.fetchDefinitionsAndImages(card: card, context: context)
        let expectation = XCTestExpectation(description: "Network call succeeds.")

        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Test: Finished without error.")
                case .failure(let error):
                    print("Test: Finished with error: \(error)")
                    XCTAssertNil(error)
                }
                expectation.fulfill()
            },
            receiveValue: { card in
                print("Test: Received card: \(card)")
                XCTAssertNotNil(card)
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
    }
    
    func testFetchTranslations_Success() {
        let publisher = sut.fetchTranslations(["text1", "text2"])
        let expectation = XCTestExpectation(description: "Network call succeeds.")

        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Test: Finished without error.")
                case .failure(let error):
                    print("Test: Finished with error: \(error)")
                    XCTAssertNil(error)
                }
                expectation.fulfill()
            },
            receiveValue: { card in
                print("Test: Received card: \(card)")
                XCTAssertNotNil(card)
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
    }
    
    func testRetryFetchingImages_Success() {
        let card = Card(context: context)
        card.text = "example"
        
        XCTAssertNil(card.imageDatasArray.first?.data)
        
        let publisher = sut.retryFetchingImages(card: card, context: context)
        let expectation = XCTestExpectation(description: "Network call succeeds.")

        publisher.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Test: Finished without error.")
                case .failure(let error):
                    print("Test: Finished with error: \(error)")
                    XCTAssertNil(error)
                }
                expectation.fulfill()
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(card.imageDatasArray.first?.data)
    }
}
