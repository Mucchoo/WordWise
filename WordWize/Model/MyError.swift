//
//  MyError.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/30/23.
//

import Foundation

enum MyError: Error {
    case textNotFound
    case imageNotFound
    case merriamWebsterConversionFailed
    case network
    case parsing
}
