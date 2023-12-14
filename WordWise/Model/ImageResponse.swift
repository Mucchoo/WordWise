//
//  ImageResponse.swift
//  WordWise
//
//  Created by Musa Yazuju on 7/16/23.
//

import Foundation

struct ImageResponse: Codable {
    let hits: [Hit]
    
    struct Hit: Codable {
        let webformatURL: String
    }
}
