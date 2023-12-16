//
//  MasteryRate.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/9/23.
//

import Foundation

enum MasteryRate: Int16 {
    case zero, twentyFive, fifty, seventyFive, oneHundred
    
    func stringValue() -> String {
        switch self {
        case .zero:
            return "0"
        case .twentyFive:
            return "25"
        case .fifty:
            return "50"
        case .seventyFive:
            return "75"
        case .oneHundred:
            return "100"
        }
    }
    
    static let allValues: [MasteryRate] = [.zero, .twentyFive, .fifty, .seventyFive, .oneHundred]
}
