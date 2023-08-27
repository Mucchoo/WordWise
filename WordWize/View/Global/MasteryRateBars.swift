//
//  MasteryRateBars.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct MasteryRateBars: View {
    let categoryName: String
    
    var body: some View {
        VStack(spacing: 8) {
            MasteryRateBar(.oneHundred, categoryName: categoryName)
            MasteryRateBar(.seventyFive, categoryName: categoryName)
            MasteryRateBar(.fifty, categoryName: categoryName)
            MasteryRateBar(.twentyFive, categoryName: categoryName)
            MasteryRateBar(.zero, categoryName: categoryName)
        }
    }
}

#Preview {
    MasteryRateBars(categoryName: "")
}

private struct MasteryRateBar: View {
    @EnvironmentObject var dataViewModel: DataViewModel

    @State private var barWidth: CGFloat = 45
    @State private var ratio: CGFloat = 0
    @State private var isLoaded = false
    @State private var countText = ""
    @State var cards: [Card] = []
    
    let rateText: String
    let colors: [Color]
    let rate: MasteryRate
    let categoryName: String
    
    var maxCount: Int {
        let rates: [MasteryRate] = [.zero, .twentyFive, .fifty, .seventyFive, .oneHundred]
        let counts = rates.map { rate -> Int in
            return cards.filter { $0.masteryRate == rate.rawValue }.count
        }
        
        let maxCount = counts.max() ?? 0
        
        return maxCount > 0 ? maxCount : 1
    }
    
    init(_ rate: MasteryRate, categoryName: String) {
        self.rate = rate
        self.categoryName = categoryName
        
        switch rate {
        case .zero:
            rateText = "0%"
            colors = [.black, .black, .navy]
        case .twentyFive:
            rateText = "25%"
            colors = [.black, .navy, .navy]
        case .fifty:
            rateText = "50%"
            colors = [.navy, .ocean, .ocean]
        case .seventyFive:
            rateText = "75%"
            colors = [.ocean, .ocean, .teal]
        case .oneHundred:
            rateText = "100%"
            colors = [.ocean, .teal, .teal]
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: barWidth, height: 30)
                    .animation(.easeInOut(duration: 1), value: barWidth)
                    .onAppear {
                        updateCards()

                        isLoaded = false
                        countText = "\(cards.filter { $0.rate == rate }.count)"
                        ratio = CGFloat(cards.filter { $0.rate == rate }.count) / CGFloat(maxCount)
                        barWidth = 90 + (geometry.size.width - 90) * ratio
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoaded = true
                        }
                    }
                HStack(spacing: 2) {
                    Text(rateText)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .font(.footnote)
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    Text(isLoaded ? countText : "")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .animation(isLoaded ? .easeInOut(duration: 1) : .none)
                    
                    Spacer()
                        .frame(width: 6)
                }
                .frame(width: 85 + ratio * (geometry.size.width - 85), height: 30)
                .animation(isLoaded ? .easeInOut(duration: 1) : .none, value: isLoaded)
            }
        }
        .frame(height: 30)
        .accessibilityIdentifier("chartBar\(rate)")
        .onReceive(dataViewModel.$cards) { _ in
            DispatchQueue.main.async {
                self.updateCards()
            }
        }
    }
    
    private func updateCards() {
        if categoryName.isEmpty {
            cards = dataViewModel.cards
        } else {
            cards = dataViewModel.cards.filter({ $0.category == categoryName })
        }
    }
}
