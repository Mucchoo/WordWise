//
//  RealNetworkServiceTests.swift
//  WordWizeTests
//
//  Created by Musa Yazici on 9/10/23.
//

import XCTest
import Combine
import CoreData
@testable import WordWize

class RealNetworkServiceTests: XCTestCase {
    var sut: RealNetworkService!
    var mockSession: URLSession!
    var cancellables: Set<AnyCancellable>!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        mockSession = .mock
        sut = RealNetworkService(session: mockSession)
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

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            var data: Data?
            
            if request.url!.absoluteString.contains("dictionaryapi.dev") {
                data = try encoder.encode([self.mockWordDefinition()])
            } else if request.url!.absoluteString.contains("pixabay.com") {
                data = try encoder.encode(self.mockImageResponse())
            }
            
            return (response, data!)
        }

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

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            var data: Data?
            
            if request.url!.absoluteString.contains("dictionaryapi.com") {
                data = try encoder.encode([self.mockMerriamWebsterResponse()])
            } else if request.url!.absoluteString.contains("pixabay.com") {
                data = try encoder.encode(self.mockImageResponse())
            }
            
            return (response, data ?? Data())
        }

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
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.mockTranslationResponse())
            
            return (response, data)
        }

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
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.mockImageResponse())
            
            return (response, data)
        }

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

    // MARK: - Mock Data
    
    private func mockWordDefinition() -> WordDefinition {
        return WordDefinition(
            word: "example",
            phonetic: "/ɪgˈzam.pəl/",
            phonetics: [
                .init(text: "phonetics 1"),
                .init(text: "phonetics 2")
            ],
            origin: "origin",
            meanings: [
                .init(
                partOfSpeech: "test",
                definitions: [
                    .init(
                        definition: "definition1",
                        example: "example1",
                        synonyms: ["synonyms1", "synonyms2"],
                        antonyms: ["antonyms1", "antonyms2"]),
                    .init(
                        definition: "definition2",
                        example: "example2",
                        synonyms: ["synonyms1", "synonyms2"],
                        antonyms: ["antonyms1", "antonyms2"])
                ])])
    }
    
    private func mockMerriamWebsterResponse() -> MerriamWebsterDefinition {
        return MerriamWebsterDefinition(
            fl: "fl", shortdef: [
                "shortdef1",
                "shortdef2"
            ])
    }
    
    private func mockImageResponse() -> ImageResponse {
        return ImageResponse(hits: [
            .init(webformatURL: "https://mock.com"),
            .init(webformatURL: "https://mock.com")
        ])
    }
    
    private func mockTranslationResponse() -> TranslationResponse {
        return TranslationResponse(translations: [
            .init(detected_source_language: "mock", text: "mock text"),
            .init(detected_source_language: "mock", text: "mock text")
        ])
    }
}
