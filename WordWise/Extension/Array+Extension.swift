//
//  Array+Extension.swift
//  WordWise
//
//  Created by Musa Yazuju on 7/16/23.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
