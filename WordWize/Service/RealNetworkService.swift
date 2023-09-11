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
    
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - fetchDefinitionsAndImages
    
    func fetchDefinitionsAndImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Card, Error> {
        guard let text = card.text else {
            return Fail(error: MyError.textNotFound).eraseToAnyPublisher()
        }
        
        let fetchCardData = fetchDefinitions(word: text).catch { error -> AnyPublisher<WordDefinition, Error> in
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let fetchImagesData = fetchImages(word: text).catch { error -> AnyPublisher<[String], Error> in
            card.retryFetchImages = true
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return Publishers.Zip(fetchCardData, fetchImagesData)
            .flatMap({ definition, imageUrls in
                self.setDefinitionData(card: card, context: context, data: definition)
                self.downloadAndSetImages(card: card, context: context, imageUrls: imageUrls)
                return Just(card).setFailureType(to: Error.self).eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndSetImages(card: Card, context: NSManagedObjectContext, imageUrls: [String]) {
        let downloadImages: [AnyPublisher<Data, Error>] = imageUrls.compactMap { url in
            guard let urlObj = URL(string: url) else { return nil }
            return session.dataTaskPublisher(for: urlObj)
                .map(\.data)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        
        _ = Publishers.MergeMany(downloadImages)
            .collect()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { imagesData in
                    for (index, data) in imagesData.enumerated() {
                        let imageData = ImageData(context: context)
                        imageData.data = data
                        imageData.priority = Int64(index)
                        card.addToImageDatas(imageData)
                    }
                }
            )
    }
        
    private func fetchDefinitionsFromMerriamWebsterAPI(word: String) -> AnyPublisher<[MerriamWebsterDefinition], Error> {
        guard let url = URL(string: merriamWebsterAPIURLString + word + "?key=" + Keys.merriamWebsterApiKey) else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
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

    private func fetchDefinitionsFromFreeAPI(word: String) -> AnyPublisher<WordDefinition, Error> {
        guard let url = URL(string: freeDictionaryAPIURLString + word) else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
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

    private func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        guard let url = URL(string: pixabayAPIURLString + "?key=\(Keys.pixabayApiKey)&q=\(word)") else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
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
            .catch { _ in
                return Fail(error: MyError.imageNotFound)
            }
            .eraseToAnyPublisher()
    }

    private func fetchDefinitions(word: String) -> AnyPublisher<WordDefinition, Error> {
        fetchDefinitionsFromFreeAPI(word: word)
            .catch { [weak self] _ in
                self?.fetchDefinitionsFromMerriamWebsterAPI(word: word)
                    .tryMap { merriamWebsterDefinitions in
                        print("Got merriamWebsterDefinitions of: \(word)")
                        switch self?.convertMerriamWebsterDefinition(word: word, data: merriamWebsterDefinitions) {
                        case .success(let convertedDefinition):
                            return convertedDefinition
                        case .failure(let error):
                            print("Cannot convert merriamWebster response of: \(word)")
                            throw error
                        case .none:
                            throw URLError(.cannotParseResponse)
                        }
                    }
                    .eraseToAnyPublisher() ?? Fail(error: URLError(.unknown)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func convertMerriamWebsterDefinition(word: String, data: [MerriamWebsterDefinition]) -> Result<WordDefinition, Error> {
        guard !data.isEmpty else {
            return .failure(MyError.merriamWebsterConversionFailed)
        }
        
        let meanings: [WordDefinition.Meaning] = data.map { data in
            let definitions: [WordDefinition.Meaning.Definition] = data.shortdef?.map { ref in
                return .init(definition: ref, example: nil, synonyms: nil, antonyms: nil)
            } ?? []
            return .init(partOfSpeech: data.fl, definitions: definitions)
        }
        
        let wordDefinition = WordDefinition(word: word, phonetic: nil, phonetics: [], origin: nil, meanings: meanings)
        return .success(wordDefinition)
    }
    
    private func setDefinitionData(card: Card, context: NSManagedObjectContext, data: WordDefinition) {
        data.meanings?.forEach { meaning in
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
        
        data.phonetics?.forEach { phonetic in
            let newPhonetic = Phonetic(context: context)
            newPhonetic.text = phonetic.text
            card.addToPhonetics(newPhonetic)
        }
    }
    
    // MARK: - fetchTranslations
    
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
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, _ in data }
            .decode(type: TranslationResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - RetryFetchingImages
    
    func retryFetchingImages(card: Card, context: NSManagedObjectContext) -> AnyPublisher<Void, Error> {
        return fetchImages(word: card.unwrappedText)
            .flatMap { imageUrls -> AnyPublisher<Void, Error> in
                card.imageDatas = nil
                
                let downloadImages = imageUrls.enumerated().map { index, url -> AnyPublisher<Data, Error> in
                    return self.session.dataTaskPublisher(for: URL(string: url)!)
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
                            card.addToImageDatas(imageData)
                        }
                    }
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

}
