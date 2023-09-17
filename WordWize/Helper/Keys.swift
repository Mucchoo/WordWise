//
//  Keys.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/16/23.
//
import Foundation

struct Keys {
    static let pixabayApiKey = ProcessInfo.processInfo.environment["PIXABAY_API_KEY"] ?? ""
    static let deepLApiKey = ProcessInfo.processInfo.environment["DEEPL_API_KEY"] ?? ""
    static let merriamWebsterApiKey = ProcessInfo.processInfo.environment["MERRIAM_WEBSTER_API_KEY"] ?? ""
}
