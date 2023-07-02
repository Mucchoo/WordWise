//
//  Global.swift
//  VocabBuilder
//
//  Created by Musa Yazuju on 7/2/23.
//

import Foundation

struct Global {
    static let maximumCardOptions = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 350, 400, 450, 500, 600, 700, 800, 900, 1000]
    static let failedTimeOptions = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
    static let statusArray  = [CardStatus(text: "learned", value: 0), CardStatus(text: "learning", value: 1), CardStatus(text: "new", value: 2)]
}
