//
//  MasteryRateCountsView.swift
//  WordWize
//
//  Created by Musa Yazuju on 7/2/23.
//

import SwiftUI

struct MasteryRateCountsView: View {
    @Binding var category: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                RateBar(masteryRate: .zero, category: $category)
                RateBar(masteryRate: .twentyFive, category: $category)
            }
            HStack(spacing: 0) {
                RateBar(masteryRate: .fifty, category: $category)
                RateBar(masteryRate: .seventyFive, category: $category)
            }
        }
        .cornerRadius(20)
        .clipped()
    }
}

private struct RateBar: View {
    @EnvironmentObject var dataViewModel: DataViewModel
    var masteryRate: MasteryRate
    @Binding var category: String
    
    var cardCount: Int {
        let categoryCards = dataViewModel.cards.filter { $0.category == category }
        let rateCards = categoryCards.filter { $0.rate == masteryRate }
        return rateCards.count
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(masteryRate.stringValue() + "%:")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 2)
            Text("\(cardCount)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("cards")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 6)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: getColors(), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    func getColors() -> [Color] {
        switch masteryRate {
        case .zero:
            return [.black, .navy]
        case .twentyFive:
            return [.navy, .ocean]
        case .fifty:
            return [.navy, .ocean]
        case .seventyFive:
            return [.ocean, .teal]
        case .oneHundred:
            return []
        }
    }
}

#Preview {
    MasteryRateCountsView(category: .constant(""))
        .injectMockDataViewModelForPreview()
}
