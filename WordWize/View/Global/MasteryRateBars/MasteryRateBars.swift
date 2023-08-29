//
//  MasteryRateBars.swift
//  WordWize
//
//  Created by Musa Yazuju on 8/13/23.
//

import SwiftUI

struct MasteryRateBars: View {
    @StateObject private var viewModel: MasteryRateBarsViewModel
    
    init(viewModel: MasteryRateBarsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            masteryRateBar(.oneHundred)
            masteryRateBar(.seventyFive)
            masteryRateBar(.fifty)
            masteryRateBar(.twentyFive)
            masteryRateBar(.zero)
        }
    }
    
    private func masteryRateBar(_ rate: MasteryRate) -> some View {
        @State var barWidth: CGFloat = 45
        @State var ratio: CGFloat = 0
        @State var isLoaded = false
        @State var countText = ""
        @State var filteredCards: [Card] = []
        
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(colors: viewModel.getColors(rate), startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 45, height: 30)
                    .animation(.easeInOut(duration: 1), value: 45)
                    .onAppear {
                        viewModel.updateCards()

                        isLoaded = false
                        countText = "\(viewModel.cards.filter { $0.rate == rate }.count)"
                        ratio = viewModel.getRatio(rate)
                        barWidth = 90 + (geometry.size.width - 90) * ratio
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            isLoaded = true
                        }
                    }
                HStack(spacing: 2) {
                    Text(viewModel.getRateText(rate))
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
        .onReceive(viewModel.container.appState.$cards) { _ in
            DispatchQueue.main.async {
                self.viewModel.updateCards()
            }
        }
    }
}

//#Preview {
//    MasteryRateBars(categoryName: "")
//}
