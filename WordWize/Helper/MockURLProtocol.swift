//
//  MockURLProtocol.swift
//  WordWize
//
//  Created by Musa Yazici on 9/12/23.
//

import Foundation

extension URLSession {
    static var mock: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

class MockURLProtocol: URLProtocol {
    static var shouldFailUrl: String?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        let (response, data) = setupMockResponse(request: request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    private func setupMockResponse(request: URLRequest) -> (HTTPURLResponse, Data?) {
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let urlString = request.url!.absoluteString
        
        var data: Data?
        
        if let url = MockURLProtocol.shouldFailUrl, urlString.contains(url) {
            MockURLProtocol.shouldFailUrl = nil
        } else if urlString.contains(APIURL.pixabay) {
            data = mockImageResponse
        } else if urlString.contains(APIURL.freeDictionary) {
            data = mockWordDefinition
        } else if urlString.contains(APIURL.merriamWebster) {
            data = mockMerriamWebsterResponse
        } else if urlString.contains(APIURL.deepL) {
            data = mockTranslationResponse
        }
        
        return (response, data)
    }
    // MARK: - Mock Data
    
    private var mockWordDefinition: Data? {
        let dataStruct = [WordDefinition(
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
                ])])]
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(dataStruct)
    }
    
    private var mockMerriamWebsterResponse: Data? {
        let dataStruct = [MerriamWebsterDefinition(
            fl: "fl", shortdef: [
                "shortdef1",
                "shortdef2"
            ])]
        
        let encoder = JSONEncoder()
        return try? encoder.encode(dataStruct)
    }
    
    private var mockImageResponse: Data? {
        let dataStruct = ImageResponse(hits: [
            .init(webformatURL: "https://mock.com"),
            .init(webformatURL: "https://mock.com")
        ])
        
        let encoder = JSONEncoder()
        return try? encoder.encode(dataStruct)
    }
    
    private var mockTranslationResponse: Data? {
        let dataStruct = TranslationResponse(translations: [
            .init(detected_source_language: "mock", text: "mock text"),
            .init(detected_source_language: "mock", text: "mock text")
        ])
        
        let encoder = JSONEncoder()
        return try? encoder.encode(dataStruct)
    }
}
