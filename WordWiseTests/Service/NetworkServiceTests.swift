//
//  NetworkServiceTests.swift
//  WordWiseTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import Combine
import SwiftData
@testable import WordWise

class NetworkServiceTests: XCTestCase {
    var sut: NetworkService!
    var mockSession: URLSession!
    var cancellables: Set<AnyCancellable>!
    var context: ModelContext!
    
    override func setUp() {
        super.setUp()
        mockSession = .mock
        sut = NetworkService(session: .mock, context: context)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        cancellables = nil
        context = nil
        MockURLProtocol.shouldFailUrls = []
        super.tearDown()
    }
    
    func testFetchDefinitionsAndImages_FreeAPI_Success() {
        let card = Card()
        card.text = "example"

        let publisher = sut.fetchDefinitionsAndImages(card: card)
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
        let card = Card()
        card.text = "example"
        
        MockURLProtocol.shouldFailUrls.append(APIURL.freeDictionary)
        let publisher = sut.fetchDefinitionsAndImages(card: card)
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
        let card = Card()
        card.text = "example"
        
        XCTAssertNil(card.imageDatas.first?.data)
        
        let publisher = sut.retryFetchingImages(card: card)
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
        XCTAssertNotNil(card.imageDatas.first?.data)
    }
}
