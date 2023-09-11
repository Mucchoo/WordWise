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
    
    override func setUp() {
        super.setUp()
        mockSession = .mock
        sut = RealNetworkService(session: mockSession)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchDefinitionsAndImages_FreeAPI_Success() {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let card = Card(context: context)
        card.text = "example"
        
        var output: Card?
        var outputError: Error?

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
                    outputError = error
                }
                expectation.fulfill()
            },
            receiveValue: { card in
                print("Test: Received card: \(card)")
                output = card
            }
        )
        .store(in: &cancellables)

        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(output)
        XCTAssertNil(outputError)
    }
    
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
    
    private func mockImageResponse() -> ImageResponse {
        return ImageResponse(hits: [
            .init(webformatURL: "https://mock.com"),
            .init(webformatURL: "https://mock.com"),
            .init(webformatURL: "https://mock.com"),
            .init(webformatURL: "https://mock.com")
        ])
    }
}
