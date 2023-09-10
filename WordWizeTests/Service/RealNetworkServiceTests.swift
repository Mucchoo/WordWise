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
        mockSession = .mockedResponsesOnly
        sut = RealNetworkService(session: mockSession)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchTranslations() {
        let mockTexts = ["hello", "world"]
        XCTAssertNoThrow(
            sut.fetchTranslations(mockTexts)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        )
    }
    
    func testFetchDefinitionsAndImages() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let card = Card(context: mockContext)
        
        XCTAssertNoThrow(
            sut.fetchDefinitionsAndImages(card: card, context: mockContext)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        )
    }
    
    func testDownloadAndSetImages() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let card = Card(context: mockContext)
        
        XCTAssertNoThrow(sut.downloadAndSetImages(card: card, context: mockContext, imageUrls: []))
    }
    
    func testRetryFetchingImages() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let mockCard = Card(context: mockContext)
        
        XCTAssertNoThrow(
            sut.retryFetchingImages(card: mockCard, context: mockContext)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        )
    }
    
    func testFetchDefinitionsFromMerriamWebsterAPI() {
        XCTAssertNoThrow(
            sut.fetchDefinitionsFromMerriamWebsterAPI(word: "")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        )
    }
    
    func testFetchDefinitionsFromFreeAPI() {
        XCTAssertNoThrow(
            sut.fetchDefinitionsFromFreeAPI(word: "")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        )
    }
    
    func testFetchImages() {
        XCTAssertNoThrow(
            sut.fetchImages(word: "")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
        )
    }
    
    func testConvertMerriamWebsterDefinition() {
        let mockData: [MerriamWebsterDefinition] = []
        XCTAssertNoThrow(_ = sut.convertMerriamWebsterDefinition(word: "", data: mockData))
    }
    
    func testSetDefinitionData() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let card = Card(context: mockContext)
        let mockData: WordDefinition = .init(word: "", phonetic: "", phonetics: [], origin: "", meanings: [])

        XCTAssertNoThrow(sut.setDefinitionData(card: card, context: mockContext, data: mockData))
    }
}

extension URLSession {
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}
