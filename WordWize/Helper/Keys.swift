//
//  Keys.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/16/23.
//
import Foundation

struct Keys {
    static let pixabayApiKey = ProcessInfo.processInfo.environment["pixabayApiKey"] ?? ""
    static let deepLApiKey = ProcessInfo.processInfo.environment["deepLApiKey"] ?? ""
    static let merriamWebsterApiKey = ProcessInfo.processInfo.environment["merriamWebsterApiKey"] ?? ""
}
