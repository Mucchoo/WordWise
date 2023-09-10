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
        mockSession = .init(configuration: .ephemeral)
        sut = RealNetworkService(session: mockSession)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchDefinitionsAndImages() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let card = Card(context: mockContext)
        sut.fetchDefinitionsAndImages(card: card, context: mockContext)
    }
    
    func testDownloadAndSetImages() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let card = Card(context: mockContext)
        sut.downloadAndSetImages(card: card, context: mockContext, imageUrls: [])
    }
    
    func testRetryFetchingImages() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let mockCard = Card(context: mockContext)
        sut.retryFetchingImages(card: mockCard, context: mockContext)
    }
    
    func testFetchDefinitionsFromMerriamWebsterAPI() {
        sut.fetchDefinitionsFromMerriamWebsterAPI(word: "")
    }
    
    func testFetchDefinitionsFromFreeAPI() {
        sut.fetchDefinitionsFromFreeAPI(word: "")
    }
    
    func testFetchImages() {
        sut.fetchImages(word: "")
    }
    
    func testFetchDefinitions() {
        sut.fetchDefinitions(word: "")
    }
    
    func testFetchTranslations() {
        let mockTexts = ["hello", "world"]
        sut.fetchTranslations(mockTexts)
    }
    
    func testConvertMerriamWebsterDefinition() {
        sut.convertMerriamWebsterDefinition(word: "", data: [])
    }
    
    func testSetDefinitionData() {
        let mockContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let card = Card(context: mockContext)
        let mockData: WordDefinition = .init(word: "", phonetic: "", phonetics: [], origin: "", meanings: [])
        sut.setDefinitionData(card: card, context: mockContext, data: mockData)
    }
}
