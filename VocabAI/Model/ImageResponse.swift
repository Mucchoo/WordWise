//
//  ImageResponse.swift
//  VocabAI
//
//  Created by Musa Yazuju on 7/16/23.
//

import Foundation

struct ImageResponse: Decodable {
    let total: Int
    let totalHits: Int
    let hits: [Hit]
}

struct Hit: Decodable {
    let id: Int
    let pageURL: String
    let type: String
    let tags: String
    let previewURL: String
    let previewWidth: Int
    let previewHeight: Int
    let webformatURL: String
    let webformatWidth: Int
    let webformatHeight: Int
    let largeImageURL: String
    let imageWidth: Int
    let imageHeight: Int
    let imageSize: Int
}
