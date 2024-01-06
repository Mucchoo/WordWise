//
//  RealNetworkService.swift
//  WordWise
//
//  Created by Musa Yazuju on 7/16/23.
//

import Foundation
import Combine

struct APIURL {
    static let freeDictionary = "https://api.dictionaryapi.dev/api/v2/entries/en/"
    static let pixabay = "https://pixabay.com/api/"
    static let merriamWebster = "https://dictionaryapi.com/api/v3/references/collegiate/json/"
    static let deepL = "https://api-free.deepl.com/v2/translate"
}

protocol NetworkServiceProtocol {
    func fetchDefinitionsAndImages(text: String) -> AnyPublisher<CardData, Error>
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<[String], Error>
    func retryFetchingImages(text: String) -> AnyPublisher<[Data], Error>
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private var cancellables = Set<AnyCancellable>()

    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - fetchDefinitionsAndImages
    
    func fetchDefinitionsAndImages(text: String) -> AnyPublisher<CardData, Error> {
        let cardData = CardData()
        
        let fetchCardData = fetchDefinitions(word: text).catch { error -> AnyPublisher<WordDefinition, Error> in
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let fetchImagesData = fetchImages(word: text).catch { error -> AnyPublisher<[String], Error> in
            cardData.retryFetchImages = true
            return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        return Publishers.Zip(fetchCardData, fetchImagesData)
            .flatMap({ definition, imageUrls in
                self.setDefinitionData(to: cardData, data: definition)
                self.downloadAndSetImages(to: cardData, imageUrls: imageUrls)
                return Just(cardData).setFailureType(to: Error.self).eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
    
    private func downloadAndSetImages(to cardData: CardData, imageUrls: [String]) {
        let downloadImages: [AnyPublisher<Data, Error>] = imageUrls.compactMap { url in
            guard let urlObj = URL(string: url) else {
                print("downloadAndSetImages url is invalid: \(url)")
                return nil
            }
            return session.dataTaskPublisher(for: urlObj)
                .map(\.data)
                .mapError { $0 as Error }
                .eraseToAnyPublisher()
        }
        
        print("downloadImages: \(downloadImages.count)")
                
        Publishers.MergeMany(downloadImages)
            .collect()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("All downloads finished.")
                    case .failure(let error):
                        print("Received error: \(error)")
                    }
                },
                receiveValue: { imagesData in
                    imagesData.forEach { data in
                        cardData.imageDatas.append(data)
                    }
                }
            )
            .store(in: &cancellables)
    }
        
    private func fetchDefinitionsFromMerriamWebsterAPI(word: String) -> AnyPublisher<[MerriamWebsterDefinition], Error> {
        guard let url = URL(string: APIURL.merriamWebster + word + "?key=" + Keys.merriamWebsterApiKey) else {
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
            .decode(type: [MerriamWebsterDefinition].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    private func fetchDefinitionsFromFreeAPI(word: String) -> AnyPublisher<WordDefinition, Error> {
        guard let url = URL(string: APIURL.freeDictionary + word) else {
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
    
    private func setDefinitionData(to cardData: CardData, data: WordDefinition) {
        data.meanings?.forEach { meaning in
            let newMeaning = Meaning()
            newMeaning.partOfSpeech = meaning.partOfSpeech ?? "Unknown"
            newMeaning.createdAt = Date()
            
            meaning.definitions?.forEach { definition in
                let newDefinition = Definition()
                newDefinition.definition = definition.definition ?? ""
                newDefinition.example = definition.example
                newDefinition.antonyms = definition.antonyms?.joined(separator: ", ") ?? ""
                newDefinition.synonyms = definition.synonyms?.joined(separator: ", ") ?? ""
                newDefinition.createdAt = Date()
                
                DispatchQueue.main.async {
                    newMeaning.definitions.append(newDefinition)
                }
            }
            
            cardData.meanings.append(newMeaning)
        }
        
        data.phonetics?.forEach { phonetic in
            let newPhonetic = Phonetic()
            newPhonetic.text = phonetic.text ?? ""
            cardData.phonetics.append(newPhonetic)
        }
    }
    
    // MARK: - fetchTranslations
    
    func fetchTranslations(_ texts: [String]) -> AnyPublisher<[String], Error> {
        let url = URL(string: APIURL.deepL)!
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
            .map { response in
                response.translations.map { $0.text }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - RetryFetchingImages
    
    func retryFetchingImages(text: String) -> AnyPublisher<[Data], Error> {
        return fetchImages(word: text)
            .flatMap { imageUrls -> AnyPublisher<[Data], Error> in
                let downloadImages = imageUrls.enumerated().map { index, url -> AnyPublisher<Data, Error> in
                    return self.session.dataTaskPublisher(for: URL(string: url)!)
                        .map(\.data)
                        .mapError { $0 as Error }
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(downloadImages)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchImages(word: String) -> AnyPublisher<[String], Error> {
        guard let url = URL(string: APIURL.pixabay + "?key=\(Keys.pixabayApiKey)&q=\(word)") else {
            print("Invalid URL for: \(word)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        print("fetchImages request: \(url)")
        
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: ImageResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { decodedResponse in
                print("fetchImages response: \(decodedResponse)")
            })
            .map { $0.hits.map { $0.webformatURL } }
            .eraseToAnyPublisher()
    }
}
