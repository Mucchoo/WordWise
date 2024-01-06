//
//  MasteryRateBarsViewModel.swift
//  WordWise
//
//  Created by Musa Yazuju on 8/28/23.
//

import SwiftUI
import Combine

class MasteryRateBarsViewModel: ObservableObject {
    let container: DIContainer
    var category: String
    @Published var isLoaded = false
    
    @Published var countTexts: [MasteryRate : String] = [
        .zero : "",
        .twentyFive : "",
        .fifty : "",
        .seventyFive : "",
        .oneHundred : ""
    ]
    
    @Published var barWidths: [MasteryRate : CGFloat] = [
        .zero : 45,
        .twentyFive : 45,
        .fifty : 45,
        .seventyFive : 45,
        .oneHundred : 45
    ]
    
    var maxCount: Int {
        let counts = MasteryRate.allValues.map { rate -> Int in
            return cards.filter { $0.masteryRate == rate.rawValue }.count
        }
        
        let maxCount = counts.max()!
        return maxCount > 0 ? maxCount : 1
    }
    
    var cards: [Card] {
        if category.isEmpty {
            return cards
        } else {
            return cards.filter({ $0.category == category })
        }
    }
    
    init(container: DIContainer, category: String) {
        self.container = container
        self.category = category
    }
    
    func getCount(_ rate: MasteryRate) -> String {
        return "\(cards.filter { $0.masteryRate == rate.rawValue }.count)"
    }
    
    func getRateText(_ rate: MasteryRate) -> String {
        switch rate {
        case .zero:
            return "0%"
        case .twentyFive:
            return "25%"
        case .fifty:
            return "50%"
        case .seventyFive:
            return "75%"
        case .oneHundred:
            return "100%"
        }
    }
    
    func getColors(_ rate: MasteryRate) -> [Color] {
        switch rate {
        case .zero:
            return [.black, .black, .navy]
        case .twentyFive:
            return [.black, .navy, .navy]
        case .fifty:
            return [.navy, .ocean, .ocean]
        case .seventyFive:
            return [.ocean, .ocean, .sky]
        case .oneHundred:
            return [.ocean, .sky, .sky]
        }
    }
    
    func getRatio(_ rate: MasteryRate) -> CGFloat {
        let count = cards.filter { $0.masteryRate == rate.rawValue }.count
        return CGFloat(count) / CGFloat(maxCount)
    }
    
    func setWidthAndCountText(geometryWidth: CGFloat) {
        MasteryRate.allValues.forEach { rate in
            barWidths[rate] = 90 + (geometryWidth - 90) * getRatio(rate)
            countTexts[rate] = "\(cards.filter { $0.rate == rate }.count)"
        }
    }
}
