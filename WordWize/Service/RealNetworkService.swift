//
//  RealNetworkService.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/16/23.
//

import Foundation
import Combine
import CoreData

class RealNetworkService: NetworkService {
    private let freeDictionaryAPIURLString = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    private let pixabayAPIURLString = "https://pixabay.com/api/"
    private let merriamWebsterAPIURLString = "https://dictionaryapi.com/api/v3/references/collegiate/json/"
    private let deepLAPIURLString = "https://api-free.deepl.com/v2/translate"
    
    func fetchAndPopulateCard(word: String, card: Card, context: NSManagedObjectContext, onFetched: @escaping () -> Void) -> AnyPublisher<Card, Error> {
        let fetchCardData = fetchDefinitions(word: word)
        let fetchImagesData = fetchImages(word: word)

        return Publishers.Zip(fetchCardData, fetchImagesData)
            .flatMap { cardResponse, imageUrls -> AnyPublisher<Card, Error> in
                print("got result of \(cardResponse.word)")
                
                cardResponse.meanings?.forEach { meaning in
                    let newMeaning = Meaning(context: context)
                    newMeaning.partOfSpeech = meaning.partOfSpeech ?? "Unknown"
                    newMeaning.createdAt = Date()
                    
                    meaning.definitions?.forEach { definition in
                        let newDefinition = Definition(context: context)
                        newDefinition.definition = definition.definition
                        newDefinition.example = definition.example
                        newDefinition.antonyms = definition.antonyms?.joined(separator: ", ") ?? ""
                        newDefinition.synonyms = definition.synonyms?.joined(separator: ", ") ?? ""
                        newDefinition.createdAt = Date()
                        
                        newMeaning.addToDefinitions(newDefinition)
                    }
                    
                    card.addToMeanings(newMeaning)
                }
                
                cardResponse.phonetics?.forEach { phonetic in
                    let newPhonetic = Phonetic(context: context)
                    newPhonetic.text = phonetic.text
                    card.addToPhonetics(newPhonetic)
                }
                
                onFetched()
                
                let downloadImages: [AnyPublisher<Data, Error>] = imageUrls.compactMap { url in
                    guard let urlObj = URL(string: url) else { return nil }
                    return URLSession.shared.dataTaskPublisher(for: urlObj)
                        .map(\.data)
                        .mapError { $0 as Error }
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(downloadImages)
                    .collect()
                    .flatMap { (imagesData: [Data]) -> AnyPublisher<Card, Error> in
                        for (index, data) in imagesData.enumerated() {
                            let imageData = ImageData(context: context) // Assuming context is accessible
                            imageData.data = data
                            imageData.priority = Int64(index)
                            imageData.retryFlag = imageUrls[index] == "error"
                            card.addToImageDatas(imageData)
                        }
                        
                        return Just(card).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                    .catch { _ in
                        return Just(card).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func retryFetchingImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return fetchImages(word: card.unwrappedText)
            .flatMap { imageUrls -> AnyPublisher<Void, Error> in
                card.imageDatas = nil
                
                let downloadImages = imageUrls.enumerated().map { index, url -> AnyPublisher<Data, Error> in
                    return URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
                        .map(\.data)
                        .mapError { $0 as Error }
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(downloadImages)
                    .collect()
                    .tryMap { imagesData in
                        for (index, data) in imagesData.enumerated() {
                            let imageData = ImageData(context: context)
                            imageData.data = data
                            imageData.priority = Int64(index)
                            imageData.retryFlag = imageUrls[index] == "error" // Replace "error" with appropriate condition
                            card.addToImageDatas(imageData)
                        }
                    }
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func fetchDefinitionsFromMerriamWebsterAPI(word: String) -> AnyPublisher<[MerriamWebsterDefinition], Error> {
        guard let url = URL(string: merriamWebsterAPIURLString + word + "?key=" + Keys.merriamWebsterApiKey) else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard httpResponse.statusCode == 200 else {
                    print("Merriam Webster API request for word: \(word) failed with status code: \(httpResponse.statusCode)")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [MerriamWebsterDefinition].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func fetchDefinitionsFromFreeAPI(word: String) -> AnyPublisher<WordDefinition, Error> {
        guard let url = URL(string: freeDictionaryAPIURLString + word) else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard httpResponse.statusCode == 200 else {
                    print("Free Dictionary API request for word: \(word) failed with status code: \(httpResponse.statusCode)")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [WordDefinition].self, decoder: JSONDecoder())
            .tryMap { responses in
                guard let response = responses.first,
                      let meanings = response.meanings,
                      meanings.count > 0 else {
                    throw URLError(.badServerResponse)
                }
                return response
            }
            .eraseToAnyPublisher()
    }

    func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        guard let url = URL(string: pixabayAPIURLString + "?key=\(Keys.pixabayApiKey)&q=\(word)") else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard httpResponse.statusCode == 200 else {
                    print("Pixabay API request for word: \(word) images failed with status code: \(httpResponse.statusCode)")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: ImageResponse.self, decoder: JSONDecoder())
            .map { $0.hits.map { $0.webformatURL } }
            .catch { _ in Result.Publisher(["error"]) }
            .eraseToAnyPublisher()
    }

    
    func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error> {
        fetchDefinitionsFromFreeAPI(word: word)
            .catch { [weak self] _ in
                self?.fetchDefinitionsFromMerriamWebsterAPI(word: word)
                    .tryMap { merriamWebsterDefinitions in
                        guard let convertedDefinition = self?.convertMerriamWebsterDefinition(word: word, data: merriamWebsterDefinitions) else {
                            print("Cannot convert merriamWebster response of: \(word)0")
                            throw URLError(.cannotParseResponse)
                        }
                        return convertedDefinition
                    }
                    .eraseToAnyPublisher() ?? Fail(error: URLError(.unknown)).eraseToAnyPublisher()
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
