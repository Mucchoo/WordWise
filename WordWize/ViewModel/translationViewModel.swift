//
//  translationViewModel.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/24/23.
//

import Combine
import Foundation

struct TranslationRequest: Codable {
    var text: [String]
    var target_lang: String
}

struct TranslationResponse: Codable {
    struct Translation: Codable {
        var detected_source_language: String
        var text: String
    }
    
    var translations: [Translation]
}

class TranslationViewModel: ObservableObject {
    func translateText(_ text: String) -> AnyPublisher<String, Error> {
        print("translate: \(text)")
        let url = URL(string: "https://api-free.deepl.com/v2/translate")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("DeepL-Auth-Key \(Keys.deepLApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = TranslationRequest(text: [text], target_lang: "DE")
        
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
            .map { $0.translations.first?.text ?? "" }
            .eraseToAnyPublisher()
    }
}
