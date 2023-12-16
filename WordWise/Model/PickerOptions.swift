//
//  PickerOptions.swift
//  WordWise
//
//  Created by Musa Yazuju on 7/2/23.
//

import Foundation

struct PickerOptions {
    static let maximumCard: [Int] = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000]
    static let failedTime: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    static let language: [Language] = [
        .init(code: "BG", name: "Bulgarian"),
        .init(code: "CS", name: "Czech"),
        .init(code: "DA", name: "Danish"),
        .init(code: "DE", name: "German"),
        .init(code: "EL", name: "Greek"),
        .init(code: "EN", name: "English"),
        .init(code: "ES", name: "Spanish"),
        .init(code: "ET", name: "Estonian"),
        .init(code: "FI", name: "Finnish"),
        .init(code: "FR", name: "French"),
        .init(code: "HU", name: "Hungarian"),
        .init(code: "ID", name: "Indonesian"),
        .init(code: "IT", name: "Italian"),
        .init(code: "JA", name: "Japanese"),
        .init(code: "KO", name: "Korean"),
        .init(code: "LT", name: "Lithuanian"),
        .init(code: "LV", name: "Latvian"),
        .init(code: "NB", name: "Norwegian"),
        .init(code: "NL", name: "Dutch"),
        .init(code: "PL", name: "Polish"),
        .init(code: "PT", name: "Portuguese"),
        .init(code: "RO", name: "Romanian"),
        .init(code: "RU", name: "Russian"),
        .init(code: "SK", name: "Slovak"),
        .init(code: "SL", name: "Slovenian"),
        .init(code: "SV", name: "Swedish"),
        .init(code: "TR", name: "Turkish"),
        .init(code: "UK", name: "Ukrainian"),
        .init(code: "ZH", name: "Chinese")
    ]
}
