//
//  MasteryRate.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/9/23.
//

import Foundation

public enum MasteryRate: Int16 {
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
}
