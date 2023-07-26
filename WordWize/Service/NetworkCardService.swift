//
//  NetworkCardService.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/16/23.
//

import Foundation
import Combine

class NetworkCardService: CardService {
    private let freeDictionaryAPIURLString = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    private let pixabayAPIURLString = "https://pixabay.com/api/"
    private let merriamWebsterAPIURLString = "https://dictionaryapi.com/api/v3/references/collegiate/json/"
    private let deepLAPIURLString = "https://api-free.deepl.com/v2/translate"
    
    func fetchDefinitionsFromMerriamWebsterAPI(word: String) -> AnyPublisher<[MerriamWebsterDefinition], Error> {
        guard let url = URL(string: merriamWebsterAPIURLString + word + "?key=" + Keys.merriamWebsterApiKey) else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [MerriamWebsterDefinition].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error> {
        fetchDefinitionsFromFreeAPI(word: word)
            .catch { [weak self] _ in
                self?.fetchDefinitionsFromMerriamWebsterAPI(word: word)
                    .tryMap { merriamWebsterDefinitions in
                        guard let convertedDefinition = self?.convertMerriamWebsterDefinition(word: word, data: merriamWebsterDefinitions) else {
                            throw URLError(.cannotParseResponse)
                        }
                        return convertedDefinition
                    }
                    .eraseToAnyPublisher() ?? Fail(error: URLError(.unknown)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchDefinitionsFromFreeAPI(word: String) -> AnyPublisher<WordDefinition, Error> {
        guard let url = URL(string: freeDictionaryAPIURLString + word) else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [WordDefinition].self, decoder: JSONDecoder())
            .tryMap { responses in
                guard let response = responses.first else {
                    throw URLError(.badServerResponse)
                }
                return response
            }
            .eraseToAnyPublisher()
    }
    
    private func convertMerriamWebsterDefinition(word: String, data: [MerriamWebsterDefinition]) -> WordDefinition {
        let meanings: [WordDefinition.Meaning] = data.map { data in
            let definitions: [WordDefinition.Meaning.Definition] = data.shortdef.map { ref in
                return .init(definition: ref, example: nil, synonyms: nil, antonyms: nil)
            }
            return .init(partOfSpeech: data.fl, definitions: definitions)
        }
        
        return .init(word: word, phonetic: nil, phonetics: [], origin: nil, meanings: meanings)
    }
    
    func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        guard let url = URL(string: pixabayAPIURLString + "?key=\(Keys.pixabayApiKey)&q=\(word)") else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: ImageResponse.self, decoder: JSONDecoder())
            .map { $0.hits.map { $0.webformatURL } }
            .eraseToAnyPublisher()
    }
    
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<TranslationResponse, Error> {
        let url = URL(string: deepLAPIURLString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("DeepL-Auth-Key \(Keys.deepLApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let targetLanguage = UserDefaults.standard.string(forKey: "nativeLanguage") ?? "JA"
        let requestData = TranslationRequest(text: texts, target_lang: targetLanguage)
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(requestData)
            request.httpBody = jsonData
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, _ in data }
            .decode(type: TranslationResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
